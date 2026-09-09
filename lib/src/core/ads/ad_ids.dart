import 'dart:io';

import 'package:flutter/foundation.dart';

/// Ad unit IDs are injected at build time. Release builds remain ad-free until
/// real IDs are supplied, preventing accidental use of Google's test inventory.
abstract final class AdIds {
  static const _configuredBanner = String.fromEnvironment('ADMOB_BANNER_ID');
  static const _configuredInterstitial = String.fromEnvironment(
    'ADMOB_INTERSTITIAL_ID',
  );

  static const _androidTestBanner = 'ca-app-pub-3940256099942544/6300978111';
  static const _androidTestInterstitial =
      'ca-app-pub-3940256099942544/1033173712';
  static const _iosTestBanner = 'ca-app-pub-3940256099942544/2934735716';
  static const _iosTestInterstitial = 'ca-app-pub-3940256099942544/4411468910';

  static bool get supported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  static String? get banner {
    if (_configuredBanner.isNotEmpty) return _configuredBanner;
    if (kReleaseMode || !supported) return null;
    return Platform.isAndroid ? _androidTestBanner : _iosTestBanner;
  }

  static String? get interstitial {
    if (_configuredInterstitial.isNotEmpty) return _configuredInterstitial;
    if (kReleaseMode || !supported) return null;
    return Platform.isAndroid ? _androidTestInterstitial : _iosTestInterstitial;
  }
}
