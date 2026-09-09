import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

/// Small boundary around the store SDK so entitlement behavior stays testable.
abstract interface class PurchaseGateway {
  Stream<List<PurchaseDetails>> get purchaseStream;

  Future<bool> isAvailable();

  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers);

  /// Returns current Play ownership, or null when this platform cannot provide
  /// an authoritative snapshot through the billing client.
  Future<List<PurchaseDetails>?> queryOwnedPurchases();

  Future<bool> buyNonConsumable(ProductDetails product);

  Future<void> restorePurchases();

  Future<void> completePurchase(PurchaseDetails purchase);
}

final class StorePurchaseGateway implements PurchaseGateway {
  StorePurchaseGateway([InAppPurchase? store])
    : _store = store ?? InAppPurchase.instance;

  final InAppPurchase _store;

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => _store.purchaseStream;

  @override
  Future<bool> isAvailable() => _store.isAvailable();

  @override
  Future<ProductDetailsResponse> queryProductDetails(Set<String> identifiers) =>
      _store.queryProductDetails(identifiers);

  @override
  Future<List<PurchaseDetails>?> queryOwnedPurchases() async {
    if (defaultTargetPlatform != TargetPlatform.android) return null;
    final addition = _store
        .getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
    final response = await addition.queryPastPurchases();
    if (response.error != null) return null;
    return response.pastPurchases;
  }

  @override
  Future<bool> buyNonConsumable(ProductDetails product) => _store
      .buyNonConsumable(purchaseParam: PurchaseParam(productDetails: product));

  @override
  Future<void> restorePurchases() => _store.restorePurchases();

  @override
  Future<void> completePurchase(PurchaseDetails purchase) =>
      _store.completePurchase(purchase);
}
