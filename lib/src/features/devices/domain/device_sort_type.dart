/// Available sorting options for the device list.
enum DeviceSortType {
  favoritesFirst,
  nameAsc,
  nameDesc,
  recentlyAdded,
  recentlyWoken,
  deviceType;

  /// Stable value used for local persistence.
  String get storageValue => name;

  /// Restores a sort type from its persisted value.
  static DeviceSortType fromStorageValue(String? value) {
    return DeviceSortType.values.firstWhere(
      (type) => type.storageValue == value,
      // Fall back to the default option when the stored value is unknown.
      orElse: () => DeviceSortType.favoritesFirst,
    );
  }
}
