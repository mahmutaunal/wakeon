import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:network_info_plus/network_info_plus.dart';

import '../../../core/network/wake_on_lan_service.dart';
import '../../share/data/device_share_file_service.dart';
import '../../share/data/device_share_manager.dart';
import '../../share/data/device_share_service.dart';
import '../../share/data/shared_device_mapper.dart';
import '../data/device_backup_service.dart';
import '../data/network_scan_service.dart';
import '../data/wake_device_repository.dart';
import '../data/wake_device_storage.dart';
import '../domain/device_sort_type.dart';
import '../domain/wake_device.dart';
import '../data/device_status_service.dart';
import '../domain/device_connection_status.dart';
import 'devices_ui_state.dart';

/// Provides local storage access for Wake-on-LAN devices.
final wakeDeviceStorageProvider = Provider<WakeDeviceStorage>((ref) {
  return const WakeDeviceStorage();
});

/// Provides the repository used by device-related presentation logic.
final wakeDeviceRepositoryProvider = Provider<WakeDeviceRepository>((ref) {
  return WakeDeviceRepository(storage: ref.watch(wakeDeviceStorageProvider));
});

/// Provides the service responsible for sending Wake-on-LAN packets.
final wakeOnLanServiceProvider = Provider<WakeOnLanService>((ref) {
  return const WakeOnLanService();
});

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo();
});

/// Provides local network scanning capabilities.
final networkScanServiceProvider = Provider<NetworkScanService>((ref) {
  return NetworkScanService(networkInfo: ref.watch(networkInfoProvider));
});

/// Provides backup import and export operations.
final deviceBackupServiceProvider = Provider<DeviceBackupService>((ref) {
  return const DeviceBackupService();
});

final devicesControllerProvider =
    AsyncNotifierProvider<DevicesController, DevicesUiState>(
      DevicesController.new,
    );

final deviceStatusServiceProvider = Provider<DeviceStatusService>(
  (ref) => const DeviceStatusService(),
);

final deviceShareFileServiceProvider = Provider<DeviceShareFileService>((ref) {
  return const DeviceShareFileService();
});

final sharedDeviceMapperProvider = Provider<SharedDeviceMapper>((ref) {
  return const SharedDeviceMapper();
});

final deviceShareServiceProvider = Provider<DeviceShareService>((ref) {
  return DeviceShareService();
});

final deviceShareManagerProvider = Provider<DeviceShareManager>((ref) {
  return DeviceShareManager(
    shareService: ref.watch(deviceShareServiceProvider),
    fileService: ref.watch(deviceShareFileServiceProvider),
    mapper: ref.watch(sharedDeviceMapperProvider),
  );
});

/// Manages device list state, persistence, sorting, backup, and wake actions.
class DevicesController extends AsyncNotifier<DevicesUiState> {
  late final WakeDeviceRepository _repository;
  late final WakeOnLanService _wakeOnLanService;
  late final DeviceBackupService _backupService;

  @override
  Future<DevicesUiState> build() async {
    _repository = ref.watch(wakeDeviceRepositoryProvider);
    _wakeOnLanService = ref.watch(wakeOnLanServiceProvider);
    _backupService = ref.watch(deviceBackupServiceProvider);

    final devices = await _repository.getDevices();
    final sortType = await _repository.getSortType();

    return DevicesUiState(
      devices: _sortDevices(devices, sortType),
      sortType: sortType,
    );
  }

  /// Adds a new device or replaces an existing device with the same ID.
  Future<void> addDevice(WakeDevice device) async {
    final currentState = _currentState;
    final updatedDevices = [
      device,
      ...currentState.devices.where((item) => item.id != device.id),
    ];

    await _setDevices(updatedDevices, currentState.sortType);
  }

  Future<void> updateDevice(WakeDevice device) async {
    final currentState = _currentState;
    final updatedDevices = currentState.devices
        .map((item) => item.id == device.id ? device : item)
        .toList();

    await _setDevices(updatedDevices, currentState.sortType);
  }

  Future<void> deleteDevice(String deviceId) async {
    final currentState = _currentState;
    final updatedDevices = currentState.devices
        .where((device) => device.id != deviceId)
        .toList();

    await _setDevices(updatedDevices, currentState.sortType);
  }

  /// Sends a Wake-on-LAN packet and updates the device wake timestamp.
  Future<void> wakeDevice(WakeDevice device) async {
    await _wakeOnLanService.wake(
      macAddress: device.macAddress,
      broadcastAddress: device.broadcastAddress,
      port: device.port,
    );

    await markDeviceAsWoken(device.id);
  }

  Future<void> markDeviceAsWoken(String deviceId) async {
    final currentState = _currentState;
    final updatedDevices = currentState.devices.map((device) {
      if (device.id != deviceId) {
        return device;
      }

      return device.copyWith(lastWakeAt: DateTime.now());
    }).toList();

    await _setDevices(updatedDevices, currentState.sortType);
  }

  Future<void> testDeviceConfiguration(WakeDevice device) async {
    await _wakeOnLanService.testConfiguration(
      macAddress: device.macAddress,
      broadcastAddress: device.broadcastAddress,
      port: device.port,
    );
  }

  Future<bool> exportBackup() async {
    final currentDevices = _currentState.devices;

    if (currentDevices.isEmpty) {
      throw const FormatException('no_devices_to_export');
    }

    return _backupService.exportDevices(currentDevices);
  }

  /// Imports backup devices and merges them with the current device list.
  Future<int> importBackup() async {
    final importedDevices = await _backupService.importDevices();

    if (importedDevices.isEmpty) {
      return 0;
    }

    final currentState = _currentState;
    // Merge by ID so imported devices update existing entries instead of duplicating them.
    final mergedById = <String, WakeDevice>{
      for (final device in currentState.devices) device.id: device,
    };

    for (final importedDevice in importedDevices) {
      mergedById[importedDevice.id] = importedDevice;
    }

    await _setDevices(mergedById.values.toList(), currentState.sortType);

    return importedDevices.length;
  }

  Future<void> toggleFavorite(String deviceId) async {
    final currentState = _currentState;
    final updatedDevices = currentState.devices.map((device) {
      if (device.id != deviceId) {
        return device;
      }

      return device.copyWith(isFavorite: !device.isFavorite);
    }).toList();

    await _setDevices(updatedDevices, currentState.sortType);
  }

  /// Updates the active sorting option and persists the preference.
  Future<void> changeSortType(DeviceSortType sortType) async {
    final currentState = _currentState;
    final sortedDevices = _sortDevices(currentState.devices, sortType);

    state = AsyncData(
      currentState.copyWith(devices: sortedDevices, sortType: sortType),
    );

    await _repository.saveSortType(sortType);
  }

  DevicesUiState get _currentState {
    return state.valueOrNull ?? DevicesUiState.initial();
  }

  Future<void> _setDevices(
    List<WakeDevice> devices,
    DeviceSortType sortType,
  ) async {
    final currentState = _currentState;
    final sortedDevices = _sortDevices(devices, sortType);

    state = AsyncData(
      currentState.copyWith(devices: sortedDevices, sortType: sortType),
    );

    await _repository.saveDevices(sortedDevices);
  }

  Future<void> refreshDeviceStatuses() async {
    final currentState = state.valueOrNull;

    if (currentState == null) {
      return;
    }

    final statusService = ref.read(deviceStatusServiceProvider);

    final updatedDevices = <WakeDevice>[];

    for (final device in currentState.devices) {
      final hostAddress = device.hostAddress?.trim();

      if (hostAddress == null || hostAddress.isEmpty) {
        updatedDevices.add(
          device.copyWith(connectionStatus: DeviceConnectionStatus.unknown),
        );

        continue;
      }

      final isOnline = await statusService.isOnline(device);

      updatedDevices.add(
        device.copyWith(
          connectionStatus: isOnline
              ? DeviceConnectionStatus.online
              : DeviceConnectionStatus.offline,
          lastSeenAt: isOnline ? DateTime.now() : device.lastSeenAt,
        ),
      );
    }

    await _setDevices(updatedDevices, currentState.sortType);
  }

  // Applies the selected sort option while keeping deterministic name fallbacks.
  List<WakeDevice> _sortDevices(
    List<WakeDevice> devices,
    DeviceSortType sortType,
  ) {
    final sortedDevices = [...devices];

    sortedDevices.sort((a, b) {
      switch (sortType) {
        case DeviceSortType.favoritesFirst:
          if (a.isFavorite != b.isFavorite) {
            return a.isFavorite ? -1 : 1;
          }

          return _compareByName(a, b);

        case DeviceSortType.nameAsc:
          return _compareByName(a, b);

        case DeviceSortType.nameDesc:
          return _compareByName(b, a);

        case DeviceSortType.recentlyAdded:
          final createdAtCompare = b.createdAt.compareTo(a.createdAt);

          if (createdAtCompare != 0) {
            return createdAtCompare;
          }

          return _compareByName(a, b);

        case DeviceSortType.recentlyWoken:
          // Devices that have never been woken are treated as the oldest entries.
          final firstWakeAt =
              a.lastWakeAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final secondWakeAt =
              b.lastWakeAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final wakeAtCompare = secondWakeAt.compareTo(firstWakeAt);

          if (wakeAtCompare != 0) {
            return wakeAtCompare;
          }

          return _compareByName(a, b);

        case DeviceSortType.deviceType:
          final typeCompare = a.type.index.compareTo(b.type.index);

          if (typeCompare != 0) {
            return typeCompare;
          }

          return _compareByName(a, b);
      }
    });

    return sortedDevices;
  }

  int _compareByName(WakeDevice first, WakeDevice second) {
    return first.name.toLowerCase().compareTo(second.name.toLowerCase());
  }
}
