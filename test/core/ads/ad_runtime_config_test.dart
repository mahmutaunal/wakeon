import 'package:flutter_test/flutter_test.dart';
import 'package:wakeon/src/core/ads/ad_runtime_config.dart';

void main() {
  test('defaults show an interstitial after each three eligible actions', () {
    const config = AdRuntimeConfig.defaults;

    expect(config.actionsBeforeFirstInterstitial, 3);
    expect(config.actionsBetweenInterstitials, 3);
    expect(config.minimumSessionSeconds, 30);
    expect(config.minimumInterstitialIntervalSeconds, 120);
  });

  test('remote values cannot weaken immutable ad safety limits', () {
    final config = AdRuntimeConfig.fromRemote(
      adsEnabled: true,
      bannerEnabled: true,
      interstitialEnabled: true,
      actionsBeforeFirstInterstitial: 0,
      actionsBetweenInterstitials: 1,
      minimumSessionSeconds: 0,
      minimumInterstitialIntervalSeconds: 1,
    );
    expect(config.actionsBeforeFirstInterstitial, 3);
    expect(config.actionsBetweenInterstitials, 3);
    expect(config.minimumSessionSeconds, 30);
    expect(config.minimumInterstitialIntervalSeconds, 120);
  });

  test('remote config can disable every ad format', () {
    final config = AdRuntimeConfig.fromRemote(
      adsEnabled: false,
      bannerEnabled: false,
      interstitialEnabled: false,
      actionsBeforeFirstInterstitial: 10,
      actionsBetweenInterstitials: 10,
      minimumSessionSeconds: 600,
      minimumInterstitialIntervalSeconds: 3600,
    );
    expect(config.adsEnabled, isFalse);
    expect(config.bannerEnabled, isFalse);
    expect(config.interstitialEnabled, isFalse);
  });
}
