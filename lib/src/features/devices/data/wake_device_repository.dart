import '../domain/wake_device.dart';
import '../domain/device_sort_type.dart';
import 'wake_device_storage.dart';

/// Repository layer that coordinates device persistence operations.
class WakeDeviceRepository {
  final WakeDeviceStorage _storage;

  const WakeDeviceRepository({required WakeDeviceStorage storage})
    : _storage = storage;

  /// Returns all saved Wake-on-LAN devices.
  Future<List<WakeDevice>> getDevices() {
    return _storage.getDevices();
  }

  /// Persists the provided device list.
  Future<void> saveDevices(List<WakeDevice> devices) {
    return _storage.saveDevices(devices);
  }

  /// Returns the user's preferred device sorting option.
  Future<DeviceSortType> getSortType() {
    return _storage.getSortType();
  }

  /// Persists the selected device sorting option.
  Future<void> saveSortType(DeviceSortType sortType) {
    return _storage.saveSortType(sortType);
  }
}
