class ReviewPromptSnapshot {
  const ReviewPromptSnapshot({
    required this.firstUseAt,
    required this.sessionCount,
    required this.successfulWakeCount,
    required this.configuredDeviceCount,
    required this.promptAttemptCount,
    this.lastPromptAttemptAt,
  });

  final DateTime firstUseAt;
  final int sessionCount;
  final int successfulWakeCount;
  final int configuredDeviceCount;
  final int promptAttemptCount;
  final DateTime? lastPromptAttemptAt;
}

class ReviewPromptPolicy {
  const ReviewPromptPolicy({
    this.minimumAge = const Duration(days: 2),
    this.minimumSessions = 2,
    this.minimumSuccessfulWakes = 3,
    this.minimumConfiguredDevices = 1,
    this.cooldown = const Duration(days: 120),
    this.maximumAttempts = 2,
  });

  final Duration minimumAge;
  final int minimumSessions;
  final int minimumSuccessfulWakes;
  final int minimumConfiguredDevices;
  final Duration cooldown;
  final int maximumAttempts;

  bool isEligible(ReviewPromptSnapshot snapshot, DateTime now) {
    if (snapshot.promptAttemptCount >= maximumAttempts) return false;
    if (now.difference(snapshot.firstUseAt) < minimumAge) return false;
    if (snapshot.sessionCount < minimumSessions) return false;
    if (snapshot.successfulWakeCount < minimumSuccessfulWakes) return false;
    if (snapshot.configuredDeviceCount < minimumConfiguredDevices) return false;
    final lastAttempt = snapshot.lastPromptAttemptAt;
    if (lastAttempt != null && now.difference(lastAttempt) < cooldown) {
      return false;
    }
    return true;
  }
}
