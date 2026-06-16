/// Defines how long a shared device file remains valid.
enum ShareExpiry { oneDay, sevenDays, thirtyDays, never }

/// Convenience helpers for resolving share expiration settings.
extension ShareExpiryExtension on ShareExpiry {
  /// Returns the validity period for the selected expiration option.
  Duration? get duration {
    switch (this) {
      case ShareExpiry.oneDay:
        return const Duration(days: 1);

      case ShareExpiry.sevenDays:
        return const Duration(days: 7);

      case ShareExpiry.thirtyDays:
        return const Duration(days: 30);

      case ShareExpiry.never:
        return null;
    }
  }
}
