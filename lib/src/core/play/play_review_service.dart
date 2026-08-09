import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'review_prompt_policy.dart';

class PlayReviewService {
  PlayReviewService({
    InAppReview? inAppReview,
    ReviewPromptPolicy policy = const ReviewPromptPolicy(),
  }) : _inAppReview = inAppReview ?? InAppReview.instance,
       _policy = policy;

  final InAppReview _inAppReview;
  final ReviewPromptPolicy _policy;

  static const _firstUseAtKey = 'review_first_use_at';
  static const _lastSessionAtKey = 'review_last_session_at';
  static const _sessionCountKey = 'review_session_count';
  static const _successfulWakeCountKey = 'review_successful_wake_count';
  static const _configuredDeviceCountKey = 'review_configured_device_count';
  static const _promptAttemptCountKey = 'review_prompt_attempt_count';
  static const _lastPromptAttemptAtKey = 'review_last_prompt_attempt_at';
  static const _sessionGap = Duration(minutes: 30);

  Future<void> recordSession() async {
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();
    preferences.setString(
      _firstUseAtKey,
      preferences.getString(_firstUseAtKey) ?? now.toIso8601String(),
    );

    final last = DateTime.tryParse(
      preferences.getString(_lastSessionAtKey) ?? '',
    );
    if (last == null || now.difference(last) >= _sessionGap) {
      await preferences.setInt(
        _sessionCountKey,
        (preferences.getInt(_sessionCountKey) ?? 0) + 1,
      );
    }
    await preferences.setString(_lastSessionAtKey, now.toIso8601String());
  }

  Future<void> recordConfiguredDeviceCount(int count) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_configuredDeviceCountKey, count);
  }

  Future<bool> recordSuccessfulWakeAndRequestIfEligible() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(
      _successfulWakeCountKey,
      (preferences.getInt(_successfulWakeCountKey) ?? 0) + 1,
    );
    return requestAutomaticallyIfEligible();
  }

  Future<bool> requestAutomaticallyIfEligible() async {
    final preferences = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final firstUse =
        DateTime.tryParse(preferences.getString(_firstUseAtKey) ?? '') ?? now;
    final lastAttempt = DateTime.tryParse(
      preferences.getString(_lastPromptAttemptAtKey) ?? '',
    );

    final eligible = _policy.isEligible(
      ReviewPromptSnapshot(
        firstUseAt: firstUse,
        sessionCount: preferences.getInt(_sessionCountKey) ?? 0,
        successfulWakeCount: preferences.getInt(_successfulWakeCountKey) ?? 0,
        configuredDeviceCount:
            preferences.getInt(_configuredDeviceCountKey) ?? 0,
        promptAttemptCount: preferences.getInt(_promptAttemptCountKey) ?? 0,
        lastPromptAttemptAt: lastAttempt,
      ),
      now,
    );
    if (!eligible || !await _inAppReview.isAvailable()) return false;

    await preferences.setInt(
      _promptAttemptCountKey,
      (preferences.getInt(_promptAttemptCountKey) ?? 0) + 1,
    );
    await preferences.setString(_lastPromptAttemptAtKey, now.toIso8601String());
    await _inAppReview.requestReview();
    return true;
  }

  /// Requests the native, in-app rating sheet on both Android and iOS.
  ///
  /// Store quotas decide whether the sheet is actually displayed, so the
  /// settings screen reports only whether the request could be submitted.
  Future<bool> requestManually() async {
    try {
      if (!await _inAppReview.isAvailable()) return false;
      await _inAppReview.requestReview();
      return true;
    } catch (_) {
      return false;
    }
  }
}
