import '../domain/device_sort_type.dart';
import '../domain/wake_device.dart';

/// Immutable UI state used by the devices screen.

class DevicesUiState {
  final List<WakeDevice> devices;
  final DeviceSortType sortType;

  const DevicesUiState({required this.devices, required this.sortType});

  /// Creates the default state shown when the feature is first loaded.
  factory DevicesUiState.initial() {
    return const DevicesUiState(
      devices: [],
      sortType: DeviceSortType.favoritesFirst,
    );
  }

  /// Creates a modified copy while preserving unchanged values.
  DevicesUiState copyWith({
    List<WakeDevice>? devices,
    DeviceSortType? sortType,
  }) {
    return DevicesUiState(
      devices: devices ?? this.devices,
      sortType: sortType ?? this.sortType,
    );
  }
}
