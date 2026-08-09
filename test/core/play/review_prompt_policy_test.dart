import 'package:flutter_test/flutter_test.dart';
import 'package:wakeon/src/core/play/review_prompt_policy.dart';

void main() {
  const policy = ReviewPromptPolicy();

  ReviewPromptSnapshot eligibleSnapshot(DateTime now) => ReviewPromptSnapshot(
    firstUseAt: now.subtract(const Duration(days: 3)),
    sessionCount: 2,
    successfulWakeCount: 3,
    configuredDeviceCount: 1,
    promptAttemptCount: 0,
  );

  test('allows a proven user after meaningful Wake-on-LAN usage', () {
    final now = DateTime(2026, 7, 24);
    expect(policy.isEligible(eligibleSnapshot(now), now), isTrue);
  });

  test('does not prompt before three successful wake operations', () {
    final now = DateTime(2026, 7, 24);
    final snapshot = ReviewPromptSnapshot(
      firstUseAt: now.subtract(const Duration(days: 3)),
      sessionCount: 2,
      successfulWakeCount: 2,
      configuredDeviceCount: 1,
      promptAttemptCount: 0,
    );
    expect(policy.isEligible(snapshot, now), isFalse);
  });

  test('respects cooldown and maximum attempt count', () {
    final now = DateTime(2026, 7, 24);
    final cooldownSnapshot = ReviewPromptSnapshot(
      firstUseAt: now.subtract(const Duration(days: 200)),
      sessionCount: 5,
      successfulWakeCount: 12,
      configuredDeviceCount: 2,
      promptAttemptCount: 1,
      lastPromptAttemptAt: now.subtract(const Duration(days: 30)),
    );
    expect(policy.isEligible(cooldownSnapshot, now), isFalse);

    final exhaustedSnapshot = ReviewPromptSnapshot(
      firstUseAt: now.subtract(const Duration(days: 200)),
      sessionCount: 5,
      successfulWakeCount: 12,
      configuredDeviceCount: 2,
      promptAttemptCount: 2,
    );
    expect(policy.isEligible(exhaustedSnapshot, now), isFalse);
  });
}
