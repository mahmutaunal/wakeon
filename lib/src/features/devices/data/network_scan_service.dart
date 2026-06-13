import 'dart:async';
import 'dart:io';

import 'package:network_info_plus/network_info_plus.dart';

import '../domain/discovered_device.dart';

/// Discovers reachable devices on the current local network.
class NetworkScanService {
  final NetworkInfo _networkInfo;

  const NetworkScanService({required NetworkInfo networkInfo})
    : _networkInfo = networkInfo;

  /// Scans the local subnet and returns reachable hosts.
  Future<List<DiscoveredDevice>> scanLocalNetwork() async {
    final wifiIp = await _networkInfo.getWifiIP();

    if (wifiIp == null || wifiIp.trim().isEmpty) {
      throw const SocketException('Could not detect local IP address.');
    }

    // Scan the current /24 subnet by iterating through common host addresses.
    final subnetPrefix = _getSubnetPrefix(wifiIp);
    final futures = <Future<DiscoveredDevice?>>[];

    for (var host = 1; host <= 254; host++) {
      final ipAddress = '$subnetPrefix.$host';

      if (ipAddress == wifiIp) {
        continue;
      }

      futures.add(_checkHost(ipAddress));
    }

    final results = await Future.wait(futures);

    final devices = results.whereType<DiscoveredDevice>().toList()
      ..sort((a, b) => _compareIp(a.ipAddress, b.ipAddress));

    return devices;
  }

  /// Derives the broadcast address from a local IPv4 address.
  String getBroadcastAddressFromIp(String ipAddress) {
    final subnetPrefix = _getSubnetPrefix(ipAddress);
    return '$subnetPrefix.255';
  }

  String _getSubnetPrefix(String ipAddress) {
    final parts = ipAddress.split('.');

    if (parts.length != 4) {
      throw FormatException('Invalid IPv4 address: $ipAddress');
    }

    return '${parts[0]}.${parts[1]}.${parts[2]}';
  }

  // Attempts to detect a reachable host using common network service ports.
  Future<DiscoveredDevice?> _checkHost(String ipAddress) async {
    final commonPorts = [80, 443, 22, 445, 3389, 9];

    for (final port in commonPorts) {
      try {
        final socket = await Socket.connect(
          ipAddress,
          port,
          timeout: const Duration(milliseconds: 180),
        );

        await socket.close();

        return DiscoveredDevice(
          ipAddress: ipAddress,
          hostname: null,
          macAddress: null,
          isReachable: true,
        );
      } catch (_) {}
    }

    return null;
  }

  // Keeps discovered devices ordered by the last IPv4 octet.
  int _compareIp(String first, String second) {
    final firstLastPart = int.tryParse(first.split('.').last) ?? 0;
    final secondLastPart = int.tryParse(second.split('.').last) ?? 0;

    return firstLastPart.compareTo(secondLastPart);
  }
}
