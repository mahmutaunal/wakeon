import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/app_settings.dart';
import 'premium_config.dart';
import 'purchase_gateway.dart';

enum PremiumStoreStatus {
  idle,
  loading,
  purchasing,
  restoring,
  unavailable,
  error,
}

final premiumControllerProvider = ChangeNotifierProvider<PremiumController>((
  ref,
) {
  return PremiumController(
    preferences: ref.watch(sharedPreferencesProvider),
    gateway: StorePurchaseGateway(),
  );
});

/// Owns the non-consumable Premium entitlement and store purchase lifecycle.
class PremiumController extends ChangeNotifier {
  PremiumController({
    required SharedPreferences preferences,
    required PurchaseGateway gateway,
    bool forcePremiumForTesting = PremiumConfig.forcePremiumForTesting,
  }) : _preferences = preferences,
       _gateway = gateway,
       _forcePremiumForTesting = forcePremiumForTesting,
       _isPremium =
           forcePremiumForTesting ||
           (preferences.getBool(PremiumConfig.entitlementKey) ?? false);

  final SharedPreferences _preferences;
  final PurchaseGateway _gateway;
  final bool _forcePremiumForTesting;

  StreamSubscription<List<PurchaseDetails>>? _purchaseSubscription;
  ProductDetails? _product;
  PremiumStoreStatus _status = PremiumStoreStatus.idle;
  bool _isPremium;
  bool _initialized = false;
  String? _errorCode;

  bool get isPremium => _isPremium;
  bool get isTestPremium => _forcePremiumForTesting;
  bool get canPurchase => !_isPremium && _product != null && !isBusy;
  bool get isBusy =>
      _status == PremiumStoreStatus.loading ||
      _status == PremiumStoreStatus.purchasing ||
      _status == PremiumStoreStatus.restoring;
  String? get localizedPrice => _product?.price;
  PremiumStoreStatus get status => _status;
  String? get errorCode => _errorCode;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    _purchaseSubscription = _gateway.purchaseStream.listen(
      _handlePurchaseUpdates,
      onError: (_) => _setFailure('purchase_stream_error'),
    );

    if (_forcePremiumForTesting) {
      notifyListeners();
      return;
    }

    _setStatus(PremiumStoreStatus.loading);
    try {
      if (!await _gateway.isAvailable()) {
        _setStatus(PremiumStoreStatus.unavailable);
        return;
      }
      final response = await _gateway.queryProductDetails({
        PremiumConfig.productId,
      });
      if (response.error != null) {
        _setFailure(response.error!.code);
        return;
      }
      _product = response.productDetails
          .where((product) => product.id == PremiumConfig.productId)
          .firstOrNull;
      if (_product == null) {
        _setStatus(PremiumStoreStatus.unavailable);
        return;
      }
      _setStatus(PremiumStoreStatus.idle);
      final ownedPurchases = await _gateway.queryOwnedPurchases();
      if (ownedPurchases != null) {
        await _reconcileOwnedPurchases(ownedPurchases);
      }
    } catch (_) {
      _setFailure('store_initialization_failed');
    }
  }

  Future<void> purchase() async {
    final product = _product;
    if (product == null || !canPurchase) return;
    _setStatus(PremiumStoreStatus.purchasing);
    try {
      final launched = await _gateway.buyNonConsumable(product);
      if (!launched) _setFailure('purchase_not_started');
    } catch (_) {
      _setFailure('purchase_not_started');
    }
  }

  Future<void> restore() async {
    if (isBusy || _forcePremiumForTesting) return;
    _setStatus(PremiumStoreStatus.restoring);
    try {
      await _gateway.restorePurchases();
      // The store publishes any restored entitlement on purchaseStream.
      if (!_isPremium) _setStatus(PremiumStoreStatus.idle);
    } catch (_) {
      _setFailure('restore_failed');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.productID != PremiumConfig.productId) continue;

      if (purchase.status == PurchaseStatus.pending) {
        _setStatus(PremiumStoreStatus.purchasing);
      } else if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // The platform has already checked the signed store transaction. A
        // future account backend can add server-side receipt verification at
        // this single boundary without changing the UI or ad integration.
        await _grantPremium();
      } else if (purchase.status == PurchaseStatus.error) {
        _setFailure(purchase.error?.code ?? 'purchase_failed');
      } else if (purchase.status == PurchaseStatus.canceled) {
        _setStatus(PremiumStoreStatus.idle);
      }

      if (purchase.pendingCompletePurchase &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored)) {
        try {
          await _gateway.completePurchase(purchase);
        } catch (_) {
          _setFailure('purchase_completion_failed');
        }
      }
    }
  }

  Future<void> _reconcileOwnedPurchases(List<PurchaseDetails> purchases) async {
    final owned = purchases.where(
      (purchase) =>
          purchase.productID == PremiumConfig.productId &&
          (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored),
    );
    if (owned.isEmpty) {
      // A successful Play ownership query is authoritative, including after a
      // refund/revocation. Keep the cache only when the store cannot be reached.
      _isPremium = false;
      await _preferences.setBool(PremiumConfig.entitlementKey, false);
      notifyListeners();
      return;
    }
    await _handlePurchaseUpdates(owned.toList());
  }

  Future<void> _grantPremium() async {
    _isPremium = true;
    await _preferences.setBool(PremiumConfig.entitlementKey, true);
    _setStatus(PremiumStoreStatus.idle);
  }

  void _setStatus(PremiumStoreStatus value) {
    _status = value;
    _errorCode = null;
    notifyListeners();
  }

  void _setFailure(String code) {
    _status = PremiumStoreStatus.error;
    _errorCode = code;
    notifyListeners();
  }

  @override
  void dispose() {
    _purchaseSubscription?.cancel();
    super.dispose();
  }
}
