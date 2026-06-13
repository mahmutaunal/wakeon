import 'dart:async';
import 'dart:io';

/// Provides Wake-on-LAN packet generation and network transmission.
class WakeOnLanService {
  const WakeOnLanService();

  /// Sends a Wake-on-LAN magic packet to the target device.
  Future<void> wake({
    required String macAddress,
    required String broadcastAddress,
    required int port,
  }) async {
    // Build the standard WOL magic packet from the provided MAC address.
    final packet = _buildMagicPacket(macAddress);
    final address = InternetAddress.tryParse(broadcastAddress);

    if (address == null) {
      throw const FormatException('Invalid broadcast address.');
    }

    final socket = await RawDatagramSocket.bind(
      InternetAddress.anyIPv4,
      0,
      reuseAddress: true,
      reusePort: true,
    );

    try {
      socket.broadcastEnabled = true;
      socket.send(packet, address, port);
      await Future<void>.delayed(const Duration(milliseconds: 250));
    } finally {
      socket.close();
    }
  }

  // Creates a Wake-on-LAN magic packet according to the WOL specification.
  List<int> _buildMagicPacket(String macAddress) {
    final cleanMacAddress = macAddress.replaceAll(RegExp(r'[^A-Fa-f0-9]'), '');

    if (cleanMacAddress.length != 12) {
      throw const FormatException('Invalid MAC address.');
    }

    final macBytes = <int>[];

    for (var index = 0; index < cleanMacAddress.length; index += 2) {
      final byte = int.parse(
        cleanMacAddress.substring(index, index + 2),
        radix: 16,
      );

      macBytes.add(byte);
    }

    return [
      ...List<int>.filled(6, 0xFF),
      for (var index = 0; index < 16; index++) ...macBytes,
    ];
  }

  /// Validates the provided Wake-on-LAN configuration without sending a packet.
  Future<void> testConfiguration({
    required String macAddress,
    required String broadcastAddress,
    required int port,
  }) async {
    _buildMagicPacket(macAddress);

    final address = InternetAddress.tryParse(broadcastAddress);

    if (address == null || address.type != InternetAddressType.IPv4) {
      throw const FormatException('invalid_broadcast_address');
    }

    if (port < 1 || port > 65535) {
      throw const FormatException('invalid_port');
    }

    RawDatagramSocket? socket;

    try {
      socket = await RawDatagramSocket.bind(
        InternetAddress.anyIPv4,
        0,
        reuseAddress: true,
        reusePort: true,
      );

      socket.broadcastEnabled = true;
    } on SocketException {
      throw const SocketException('udp_socket_failed');
    } finally {
      socket?.close();
    }
  }
}
