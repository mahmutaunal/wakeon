import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../settings/app_settings.dart';
import '../premium/premium_controller.dart';
import 'ad_analytics.dart';
import 'ad_ids.dart';
import 'ad_remote_config.dart';
import 'ad_runtime_config.dart';

enum BannerLoadState { initializing, loading, loaded, unavailable }

enum CompletedAdAction { deviceCreated, deviceUpdated, backupImported }

final adCoordinatorProvider = ChangeNotifierProvider<AdCoordinator>((ref) {
  final isPremium = ref.watch(
    premiumControllerProvider.select((controller) => controller.isPremium),
  );
  return AdCoordinator(
    preferences: ref.watch(sharedPreferencesProvider),
    isPremium: isPremium,
  );
});

/// Owns the complete mobile-ad lifecycle for the single Flutter activity.
class AdCoordinator extends ChangeNotifier with WidgetsBindingObserver {
  AdCoordinator({
    required SharedPreferences preferences,
    this.isPremium = false,
  }) : _preferences = preferences;

  static const _lastShownAtKey = 'ads.interstitial.last_shown_at';
  static const _maxBannerLoadAttemptsPerSession = 8;
  static const _maxInterstitialLoadAttemptsPerSession = 6;

  final SharedPreferences _preferences;
  final bool isPremium;
  final AdAnalytics _analytics = AdAnalytics();
  final AdRemoteConfig _remoteConfig = AdRemoteConfig();
  final DateTime _sessionStartedAt = DateTime.now();

  AdRuntimeConfig _config = AdRuntimeConfig.defaults;
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  Timer? _bannerRetryTimer;
  Timer? _interstitialRetryTimer;
  Timer? _pendingShowTimer;
  BannerLoadState _bannerState = BannerLoadState.initializing;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;
  bool _initialized = false;
  bool _initializing = false;
  bool _canRequestAds = false;
  bool _privacyOptionsRequired = false;
  bool _interstitialLoading = false;
  bool _interstitialShowing = false;
  TrackingStatus? _iosTrackingStatus;
  int _completedActions = 0;
  int _actionsSinceLastInterstitial = 0;
  bool _hasShownInterstitialThisSession = false;
  int _bannerFailures = 0;
  int _interstitialFailures = 0;
  int _bannerAttemptsThisSession = 0;
  int _interstitialAttemptsThisSession = 0;

  BannerAd? get bannerAd => _bannerAd;
  BannerLoadState get bannerState => _bannerState;
  bool get shouldReserveBannerSpace =>
      !isPremium &&
      AdIds.supported &&
      _config.adsEnabled &&
      _config.bannerEnabled;
  bool get privacyOptionsRequired => _privacyOptionsRequired;

  Future<void> initialize() async {
    if (_initialized || _initializing || isPremium || !AdIds.supported) return;
    _initializing = true;
    WidgetsBinding.instance.addObserver(this);
    await _analytics.initialize();
    await _loadRemoteConfig();
    await _refreshConsent();
    await _requestIosTrackingAuthorization();
    await _applyAnalyticsCollection();
    _initialized = true;
    _initializing = false;

    if (_canRequestAds && _config.adsEnabled) {
      await MobileAds.instance.initialize();
      _loadBanner();
      _loadInterstitial();
    } else {
      _setBannerState(BannerLoadState.unavailable);
    }
  }

  Future<void> _loadRemoteConfig() async {
    _config = await _remoteConfig.load();
  }

  Future<void> _refreshConsent() async {
    final completer = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((_) {});
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
        _privacyOptionsRequired =
            await ConsentInformation.instance
                .getPrivacyOptionsRequirementStatus() ==
            PrivacyOptionsRequirementStatus.required;
        final status = await ConsentInformation.instance.getConsentStatus();
        await _analytics.setConsentStatus(status.name);
        notifyListeners();
        if (!completer.isCompleted) completer.complete();
      },
      (error) async {
        // Cached consent may still legally permit requests during a refresh
        // failure. UMP is the source of truth for this decision.
        _canRequestAds = await ConsentInformation.instance.canRequestAds();
        await _analytics.event(
          'ad_consent_error',
          format: 'consent',
          placement: 'app_launch',
          reason: '${error.errorCode}',
        );
        if (!completer.isCompleted) completer.complete();
      },
    );
    await completer.future.timeout(
      const Duration(seconds: 15),
      onTimeout: () {},
    );
  }

  /// Requests ATT only for the ad-supported iOS experience and always before
  /// Mobile Ads is initialized or an ad request can be created.
  ///
  /// If an AdMob UMP IDFA explainer is configured, UMP may already have caused
  /// the system prompt to be shown. Re-reading the status prevents a duplicate
  /// request in that case. Denial never blocks the app or contextual ads.
  Future<void> _requestIosTrackingAuthorization() async {
    if (!Platform.isIOS || !_config.adsEnabled || !_canRequestAds) return;
    try {
      var status = await AppTrackingTransparency.trackingAuthorizationStatus;
      if (status == TrackingStatus.notDetermined) {
        // ATT can only present while the first Flutter scene is active and no
        // other permission sheet (including UMP) is being dismissed.
        await WidgetsBinding.instance.endOfFrame;
        await Future<void>.delayed(const Duration(milliseconds: 350));
        status = await AppTrackingTransparency.requestTrackingAuthorization();
      }
      _iosTrackingStatus = status;
    } catch (_) {
      // A restricted device or unavailable framework must still be able to use
      // the app and receive non-personalized/contextual ad requests.
    }
  }

  Future<void> _applyAnalyticsCollection() async {
    final trackingAllowed =
        !Platform.isIOS || _iosTrackingStatus == TrackingStatus.authorized;
    await _analytics.setCollectionEnabled(_canRequestAds && trackingAllowed);
    if (_iosTrackingStatus case final status?) {
      await _analytics.event(
        'att_authorization_resolved',
        format: 'privacy',
        placement: 'app_launch',
        reason: status.name,
      );
    }
  }

  Future<bool> showPrivacyOptions() async {
    if (!_privacyOptionsRequired) return false;
    final completer = Completer<bool>();
    ConsentForm.showPrivacyOptionsForm((error) {
      if (!completer.isCompleted) completer.complete(error == null);
    });
    if (!await completer.future) return false;
    _canRequestAds = await ConsentInformation.instance.canRequestAds();
    _privacyOptionsRequired =
        await ConsentInformation.instance
            .getPrivacyOptionsRequirementStatus() ==
        PrivacyOptionsRequirementStatus.required;
    await _applyAnalyticsCollection();
    // Recreate loaded inventory so the next request immediately carries the
    // user's latest UMP/consent-mode signals.
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _bannerAd = null;
    _interstitialAd = null;
    _bannerRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
    if (_canRequestAds && _config.adsEnabled) {
      _loadBanner();
      _loadInterstitial();
    } else {
      _setBannerState(BannerLoadState.unavailable);
    }
    notifyListeners();
    return true;
  }

  void _loadBanner() {
    final adUnitId = AdIds.banner;
    if (!_canLoad || !_config.bannerEnabled || adUnitId == null) {
      _setBannerState(BannerLoadState.unavailable);
      return;
    }
    if (_bannerAd != null ||
        _bannerRetryTimer?.isActive == true ||
        _bannerAttemptsThisSession >= _maxBannerLoadAttemptsPerSession) {
      return;
    }

    _bannerAttemptsThisSession++;
    _setBannerState(BannerLoadState.loading);
    final ad = BannerAd(
      size: AdSize.banner,
      adUnitId: adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (loadedAd) {
          _bannerFailures = 0;
          _bannerAd = loadedAd as BannerAd;
          _setBannerState(BannerLoadState.loaded);
          _analytics.event(
            'ad_loaded',
            format: 'banner',
            placement: 'app_bottom',
          );
        },
        onAdFailedToLoad: (failedAd, error) {
          failedAd.dispose();
          _bannerAd = null;
          _analytics.event(
            'ad_load_failed',
            format: 'banner',
            placement: 'app_bottom',
            reason: '${error.code}',
          );
          _scheduleBannerRetry();
        },
        onAdImpression: (_) => _analytics.event(
          'ad_impression',
          format: 'banner',
          placement: 'app_bottom',
        ),
      ),
    );
    ad.load();
  }

  void _scheduleBannerRetry() {
    if (!_canLoad ||
        _bannerAttemptsThisSession >= _maxBannerLoadAttemptsPerSession) {
      _setBannerState(BannerLoadState.unavailable);
      return;
    }
    _bannerFailures++;
    _setBannerState(BannerLoadState.loading);
    _bannerRetryTimer = Timer(_backoff(_bannerFailures, 120), _loadBanner);
  }

  void _loadInterstitial() {
    final adUnitId = AdIds.interstitial;
    if (!_canLoad ||
        !_config.interstitialEnabled ||
        adUnitId == null ||
        _interstitialAd != null ||
        _interstitialLoading ||
        _interstitialRetryTimer?.isActive == true ||
        _interstitialAttemptsThisSession >=
            _maxInterstitialLoadAttemptsPerSession) {
      return;
    }

    _interstitialLoading = true;
    _interstitialAttemptsThisSession++;
    InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialLoading = false;
          _interstitialFailures = 0;
          _interstitialAd = ad;
          _analytics.event(
            'ad_loaded',
            format: 'interstitial',
            placement: 'completed_action',
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialLoading = false;
          _analytics.event(
            'ad_load_failed',
            format: 'interstitial',
            placement: 'completed_action',
            reason: '${error.code}',
          );
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    if (!_canLoad ||
        _interstitialAttemptsThisSession >=
            _maxInterstitialLoadAttemptsPerSession) {
      return;
    }
    _interstitialFailures++;
    _interstitialRetryTimer = Timer(
      _backoff(_interstitialFailures, 300),
      _loadInterstitial,
    );
  }

  Duration _backoff(int failures, int maxSeconds) {
    final exponent = (failures - 1).clamp(0, 8);
    final seconds = (2 * (1 << exponent)).clamp(2, maxSeconds);
    return Duration(seconds: seconds);
  }

  /// Counts only completed, user-initiated value events. It never delays or
  /// blocks the action itself and intentionally excludes wake/test/delete taps.
  Future<void> recordCompletedAction(CompletedAdAction action) async {
    _completedActions++;
    _actionsSinceLastInterstitial++;
    await _analytics.event(
      'ad_eligible_action',
      format: 'interstitial',
      placement: action.name,
    );
    if (!_isInterstitialEligible) {
      _loadInterstitial();
      return;
    }

    // A short quiet period prevents the full-screen ad from replacing a screen
    // under a still-tapping finger.
    _pendingShowTimer?.cancel();
    _pendingShowTimer = Timer(const Duration(milliseconds: 900), () {
      if (_isInterstitialEligible) _showInterstitial();
    });
  }

  bool get _isInterstitialEligible {
    if (!_canLoad ||
        !_config.interstitialEnabled ||
        _interstitialAd == null ||
        _interstitialShowing ||
        DateTime.now().difference(_sessionStartedAt).inSeconds <
            _config.minimumSessionSeconds) {
      return false;
    }
    final requiredActions = !_hasShownInterstitialThisSession
        ? _config.actionsBeforeFirstInterstitial
        : _config.actionsBetweenInterstitials;
    final currentActions = !_hasShownInterstitialThisSession
        ? _completedActions
        : _actionsSinceLastInterstitial;
    if (currentActions < requiredActions) return false;

    final lastShownMilliseconds = _preferences.getInt(_lastShownAtKey);
    if (lastShownMilliseconds == null) return true;
    final elapsed = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(lastShownMilliseconds),
    );
    return elapsed.inSeconds >= _config.minimumInterstitialIntervalSeconds;
  }

  Future<void> _showInterstitial() async {
    final ad = _interstitialAd;
    if (ad == null || !_isInterstitialEligible) return;
    _interstitialAd = null;
    _interstitialShowing = true;
    ad.fullScreenContentCallback = FullScreenContentCallback<InterstitialAd>(
      onAdShowedFullScreenContent: (_) async {
        _hasShownInterstitialThisSession = true;
        _actionsSinceLastInterstitial = 0;
        await _preferences.setInt(
          _lastShownAtKey,
          DateTime.now().millisecondsSinceEpoch,
        );
        await _analytics.event(
          'ad_impression',
          format: 'interstitial',
          placement: 'completed_action',
        );
      },
      onAdDismissedFullScreenContent: (dismissedAd) {
        dismissedAd.dispose();
        _interstitialShowing = false;
        _loadInterstitial();
      },
      onAdFailedToShowFullScreenContent: (failedAd, error) {
        failedAd.dispose();
        _interstitialShowing = false;
        _analytics.event(
          'ad_show_failed',
          format: 'interstitial',
          placement: 'completed_action',
          reason: '${error.code}',
        );
        _scheduleInterstitialRetry();
      },
    );
    await ad.show();
  }

  bool get _canLoad =>
      !isPremium &&
      _canRequestAds &&
      _config.adsEnabled &&
      _lifecycleState == AppLifecycleState.resumed;

  void _setBannerState(BannerLoadState state) {
    _bannerState = state;
    notifyListeners();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
    if (state == AppLifecycleState.resumed) {
      _bannerFailures = 0;
      _interstitialFailures = 0;
      _loadBanner();
      _loadInterstitial();
      return;
    }
    _bannerRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
    _pendingShowTimer?.cancel();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bannerRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
    _pendingShowTimer?.cancel();
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }
}
