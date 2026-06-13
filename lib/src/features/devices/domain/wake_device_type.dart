/// Supported device categories used for organization and presentation.
enum WakeDeviceType {
  desktop,
  laptop,
  server,
  nas,
  router,
  other;

  /// Stable value used for local persistence.
  String get storageValue {
    return name;
  }

  /// Restores a device type from its persisted value.
  static WakeDeviceType fromStorageValue(String? value) {
    return WakeDeviceType.values.firstWhere(
      (type) => type.storageValue == value,
      // Fall back to a safe default when the stored value is unknown.
      orElse: () => WakeDeviceType.desktop,
    );
  }
}
