import '../../devices/domain/wake_device.dart';
import '../domain/shared_device_payload.dart';

/// Maps application devices into shareable payload models.
class SharedDeviceMapper {
  const SharedDeviceMapper();

  /// Converts a [WakeDevice] into a serializable share payload.
  SharedDevicePayload fromDevice(WakeDevice device) {
    return SharedDevicePayload(
      name: device.name,
      macAddress: device.macAddress,
      hostAddress: device.hostAddress,
      broadcastAddress: device.broadcastAddress,
      port: device.port,
      type: device.type.storageValue,
    );
  }
}
