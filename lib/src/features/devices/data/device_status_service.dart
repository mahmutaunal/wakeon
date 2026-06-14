import 'dart:io';

import '../domain/wake_device.dart';

class DeviceStatusService {
  const DeviceStatusService();

  Future<bool> isOnline(WakeDevice device) async {
    final hostAddress = device.hostAddress?.trim();

    if (hostAddress == null || hostAddress.isEmpty) {
      return false;
    }

    final commonPorts = [80, 443, 22, 445, 3389];

    for (final port in commonPorts) {
      final reachable = await _canConnect(hostAddress: hostAddress, port: port);

      if (reachable) {
        return true;
      }
    }

    return false;
  }

  Future<bool> _canConnect({
    required String hostAddress,
    required int port,
  }) async {
    Socket? socket;

    try {
      socket = await Socket.connect(
        hostAddress,
        port,
        timeout: const Duration(milliseconds: 450),
      );

      return true;
    } catch (_) {
      return false;
    } finally {
      await socket?.close();
    }
  }
}
