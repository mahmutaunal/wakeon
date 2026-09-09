/// Store and development configuration for Wakeon Premium.
abstract final class PremiumConfig {
  /// Must exactly match the one-time product ID in Play Console/App Store.
  static const productId = 'wakeon_premium';

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
