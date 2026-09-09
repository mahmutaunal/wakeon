import 'dart:math' as math;

/// Advertising defaults and hard, client-side safety limits.
///
/// Remote Config can make ads less frequent (or turn them off), but values are
/// clamped here so a console mistake can never create an aggressive ad loop.
class AdRuntimeConfig {
  static const defaults = AdRuntimeConfig(
    adsEnabled: true,
    bannerEnabled: true,
    interstitialEnabled: true,
    actionsBeforeFirstInterstitial: 3,
    actionsBetweenInterstitials: 3,
    minimumSessionSeconds: 30,
    minimumInterstitialIntervalSeconds: 120,
  );

  static const int _minActionsBeforeFirst = 3;
  static const int _minActionsBetween = 3;
  static const int _minSessionSeconds = 30;
  static const int _minIntervalSeconds = 120;
  final bool adsEnabled;
  final bool bannerEnabled;
  final bool interstitialEnabled;
  final int actionsBeforeFirstInterstitial;
  final int actionsBetweenInterstitials;
  final int minimumSessionSeconds;
  final int minimumInterstitialIntervalSeconds;

  const AdRuntimeConfig({
    required this.adsEnabled,
    required this.bannerEnabled,
    required this.interstitialEnabled,
    required this.actionsBeforeFirstInterstitial,
    required this.actionsBetweenInterstitials,
    required this.minimumSessionSeconds,
    required this.minimumInterstitialIntervalSeconds,
  });

  factory AdRuntimeConfig.fromRemote({
    required bool adsEnabled,
    required bool bannerEnabled,
    required bool interstitialEnabled,
    required int actionsBeforeFirstInterstitial,
    required int actionsBetweenInterstitials,
    required int minimumSessionSeconds,
    required int minimumInterstitialIntervalSeconds,
  }) {
    return AdRuntimeConfig(
      adsEnabled: adsEnabled,
      bannerEnabled: bannerEnabled,
      interstitialEnabled: interstitialEnabled,
      actionsBeforeFirstInterstitial: math.max(
        _minActionsBeforeFirst,
        actionsBeforeFirstInterstitial,
      ),
      actionsBetweenInterstitials: math.max(
        _minActionsBetween,
        actionsBetweenInterstitials,
      ),
      minimumSessionSeconds: math.max(
        _minSessionSeconds,
        minimumSessionSeconds,
      ),
      minimumInterstitialIntervalSeconds: math.max(
        _minIntervalSeconds,
        minimumInterstitialIntervalSeconds,
      ),
    );
  }

  static const remoteDefaults = <String, Object>{
    'ads_enabled': true,
    'ad_banner_enabled': true,
    'ad_interstitial_enabled': true,
    'ad_actions_before_first_interstitial': 3,
    'ad_actions_between_interstitials': 3,
    'ad_minimum_session_seconds': 30,
    'ad_minimum_interstitial_interval_seconds': 120,
  };
}
