import 'dart:io';

import 'package:flutter/foundation.dart';

/// Platform-isolated AdMob unit IDs.
///
/// iOS production units are intentionally kept separate from Android build
/// defines. Android release builds remain ad-free until their own IDs are
/// supplied, preventing either storefront from serving the other's inventory.
abstract final class AdIds {
  static const _androidBanner = String.fromEnvironment(
    'ADMOB_ANDROID_BANNER_ID',
  );
  static const _androidInterstitial = String.fromEnvironment(
    'ADMOB_ANDROID_INTERSTITIAL_ID',
  );
  static const _iosBanner = String.fromEnvironment(
    'ADMOB_IOS_BANNER_ID',
    defaultValue: 'ca-app-pub-5963947262278027/1630132627',
  );
  static const _iosInterstitial = String.fromEnvironment(
    'ADMOB_IOS_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-5963947262278027/2615911230',
  );

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String? get banner {
    if (!supported) return null;
    if (!kReleaseMode) {
      return Platform.isAndroid ? _androidTestBanner : _iosTestBanner;
    }
    final configured = Platform.isAndroid ? _androidBanner : _iosBanner;
    return configured.isEmpty ? null : configured;
  }

  static String? get interstitial {
    if (!supported) return null;
    if (!kReleaseMode) {
      return Platform.isAndroid
          ? _androidTestInterstitial
          : _iosTestInterstitial;
    }
    final configured = Platform.isAndroid
        ? _androidInterstitial
        : _iosInterstitial;
    return configured.isEmpty ? null : configured;
  }
}
