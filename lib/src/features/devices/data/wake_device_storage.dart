import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/wake_device.dart';
import '../domain/device_sort_type.dart';

/// Handles local persistence of devices and user preferences.
class WakeDeviceStorage {
  static const _devicesKey = 'wake_devices';
  static const _sortTypeKey = 'device_sort_type';

  const WakeDeviceStorage();

  /// Loads all saved devices from local storage.
  Future<List<WakeDevice>> getDevices() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_devicesKey);

    if (rawValue == null || rawValue.trim().isEmpty) {
      return [];
    }

    final decodedValue = jsonDecode(rawValue);

    // Ignore invalid data to prevent crashes caused by corrupted storage.
    if (decodedValue is! List) {
      return [];
    }

    return decodedValue
        .whereType<Map<String, dynamic>>()
        .map(WakeDevice.fromJson)
        .toList();
  }

  /// Saves the current device list to local storage.
  Future<void> saveDevices(List<WakeDevice> devices) async {
    final preferences = await SharedPreferences.getInstance();

    final encodedValue = jsonEncode(
      devices.map((device) => device.toJson()).toList(),
    );

    await preferences.setString(_devicesKey, encodedValue);
  }

  /// Loads the user's preferred device sorting option.
  Future<DeviceSortType> getSortType() async {
    final preferences = await SharedPreferences.getInstance();
    final rawValue = preferences.getString(_sortTypeKey);

    return DeviceSortType.fromStorageValue(rawValue);
  }

  /// Saves the selected device sorting option.
  Future<void> saveSortType(DeviceSortType sortType) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_sortTypeKey, sortType.storageValue);
  }
}
