import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';

import 'ad_runtime_config.dart';

class AdRemoteConfig {
  Future<AdRuntimeConfig> load() async {
    try {
      if (Firebase.apps.isEmpty) await Firebase.initializeApp();
      final remote = FirebaseRemoteConfig.instance;
      await remote.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 10),
          minimumFetchInterval: const Duration(hours: 6),
        ),
      );
      await remote.setDefaults(AdRuntimeConfig.remoteDefaults);
      await remote.fetchAndActivate();

      return AdRuntimeConfig.fromRemote(
        adsEnabled: remote.getBool('ads_enabled'),
        bannerEnabled: remote.getBool('ad_banner_enabled'),
        interstitialEnabled: remote.getBool('ad_interstitial_enabled'),
        actionsBeforeFirstInterstitial: remote.getInt(
          'ad_actions_before_first_interstitial',
        ),
        actionsBetweenInterstitials: remote.getInt(
          'ad_actions_between_interstitials',
        ),
        minimumSessionSeconds: remote.getInt('ad_minimum_session_seconds'),
        minimumInterstitialIntervalSeconds: remote.getInt(
          'ad_minimum_interstitial_interval_seconds',
        ),
      );
    } catch (_) {
      return AdRuntimeConfig.defaults;
    }
  }
}
