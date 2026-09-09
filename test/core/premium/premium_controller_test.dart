import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeon/src/core/premium/premium_config.dart';
import 'package:wakeon/src/core/premium/premium_controller.dart';
import 'package:wakeon/src/core/premium/purchase_gateway.dart';

class _FakePurchaseGateway implements PurchaseGateway {
  final updates = StreamController<List<PurchaseDetails>>.broadcast();
  bool available = true;
  bool buyCalled = false;
  bool restoreCalled = false;
  bool completeCalled = false;
  List<PurchaseDetails>? ownedPurchases;

  final product = ProductDetails(
    id: PremiumConfig.productId,
    title: 'Premium',
    description: 'Remove ads',
    price: '₺99,99',
    rawPrice: 99.99,
    currencyCode: 'TRY',
  );

  @override
  Stream<List<PurchaseDetails>> get purchaseStream => updates.stream;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ProductDetailsResponse> queryProductDetails(
    Set<String> identifiers,
  ) async {
    return ProductDetailsResponse(productDetails: [product], notFoundIDs: []);
  }

  @override
  Future<List<PurchaseDetails>?> queryOwnedPurchases() async => ownedPurchases;

  @override
  Future<bool> buyNonConsumable(ProductDetails product) async {
    buyCalled = true;
    return true;
  }

  @override
  Future<void> restorePurchases() async {
    restoreCalled = true;
  }

  @override
  Future<void> completePurchase(PurchaseDetails purchase) async {
    completeCalled = true;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loads the product and requests restoration on startup', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final gateway = _FakePurchaseGateway();
    final controller = PremiumController(
      preferences: preferences,
      gateway: gateway,
    );

    await controller.initialize();

    expect(controller.localizedPrice, '₺99,99');
    expect(controller.canPurchase, isTrue);
    expect(gateway.restoreCalled, isTrue);
    controller.dispose();
    await gateway.updates.close();
  });

  test('successful store update grants and persists Premium', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final gateway = _FakePurchaseGateway();
    final controller = PremiumController(
      preferences: preferences,
      gateway: gateway,
    );
    await controller.initialize();

    final purchase = PurchaseDetails(
      purchaseID: 'test-order',
      productID: PremiumConfig.productId,
      verificationData: PurchaseVerificationData(
        localVerificationData: 'local',
        serverVerificationData: 'server',
        source: 'test',
      ),
      transactionDate: '1',
      status: PurchaseStatus.purchased,
    )..pendingCompletePurchase = true;
    gateway.updates.add([purchase]);
    await Future<void>.delayed(Duration.zero);

    expect(controller.isPremium, isTrue);
    expect(gateway.completeCalled, isTrue);
    expect(preferences.getBool('premium.remove_ads.entitled'), isTrue);
    controller.dispose();
    await gateway.updates.close();
  });

  test('test override enables Premium without touching the store', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final gateway = _FakePurchaseGateway();
    final controller = PremiumController(
      preferences: preferences,
      gateway: gateway,
      forcePremiumForTesting: true,
    );

    await controller.initialize();

    expect(controller.isPremium, isTrue);
    expect(controller.isTestPremium, isTrue);
    expect(gateway.restoreCalled, isFalse);
    expect(preferences.getBool('premium.remove_ads.entitled'), isNull);
    controller.dispose();
    await gateway.updates.close();
  });

  test(
    'authoritative Play ownership snapshot clears a revoked cache',
    () async {
      SharedPreferences.setMockInitialValues({
        'premium.remove_ads.entitled': true,
      });
      final preferences = await SharedPreferences.getInstance();
      final gateway = _FakePurchaseGateway()..ownedPurchases = [];
      final controller = PremiumController(
        preferences: preferences,
        gateway: gateway,
      );

      await controller.initialize();

      expect(controller.isPremium, isFalse);
      expect(preferences.getBool('premium.remove_ads.entitled'), isFalse);
      expect(gateway.restoreCalled, isFalse);
      controller.dispose();
      await gateway.updates.close();
    },
  );
}
