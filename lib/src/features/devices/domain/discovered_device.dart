/// Represents a device discovered during a local network scan.
class DiscoveredDevice {
  final String ipAddress;
  final String? hostname;
  final String? macAddress;
  final bool isReachable;

  const DiscoveredDevice({
    required this.ipAddress,
    this.hostname,
    this.macAddress,
    required this.isReachable,
  });

  /// Indicates whether the device has a valid MAC address.
  bool get hasMacAddress {
    return macAddress != null && macAddress!.trim().isNotEmpty;
  }
}
