import 'package:flutter/foundation.dart';

/// Store and development configuration for Wakeon Premium.
abstract final class PremiumConfig {
  /// These IDs belong to independent products in their respective stores.
  /// Keep the Android default stable because it is already used by Play.
  static const androidProductId = String.fromEnvironment(
    'ANDROID_PREMIUM_PRODUCT_ID',
    defaultValue: 'wakeon_premium',
  );
  static const iosProductId = String.fromEnvironment(
    'IOS_PREMIUM_PRODUCT_ID',
    defaultValue: 'wakeon_premium_ios',
  );

  static String get productId => productIdFor(defaultTargetPlatform);

  static String productIdFor(TargetPlatform platform) => switch (platform) {
    TargetPlatform.iOS => iosProductId,
    _ => androidProductId,
  };

  static String get entitlementKey =>
      defaultTargetPlatform == TargetPlatform.iOS
      ? 'premium.remove_ads.entitled.ios'
      : 'premium.remove_ads.entitled';

  /// Development-only entitlement override.
  ///
  /// Run with `--dart-define=WAKEON_FORCE_PREMIUM=true` to exercise the whole
  /// ad-free UI without making a purchase. Release builds deliberately ignore
  /// the override so it cannot be enabled accidentally in a store artifact.
  static const _requestedTestPremium = bool.fromEnvironment(
    'WAKEON_FORCE_PREMIUM',
  );

  static const forcePremiumForTesting = bool.fromEnvironment('dart.vm.product')
      ? false
      : _requestedTestPremium;
}
