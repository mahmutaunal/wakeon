/// Represents the device data that can be transferred through sharing.
class SharedDevicePayload {
  final String name;
  final String macAddress;
  final String? hostAddress;
  final String broadcastAddress;
  final int port;
  final String type;

  const SharedDevicePayload({
    required this.name,
    required this.macAddress,
    required this.broadcastAddress,
    required this.port,
    required this.type,
    this.hostAddress,
  });

  /// Creates a payload instance from serialized JSON data.
  factory SharedDevicePayload.fromJson(Map<String, dynamic> json) {
    return SharedDevicePayload(
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      hostAddress: json['hostAddress'] as String?,
      broadcastAddress: json['broadcastAddress'] as String,
      port: json['port'] as int,
      type: json['type'] as String,
    );
  }

  /// Converts this payload into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'macAddress': macAddress,
      'hostAddress': hostAddress,
      'broadcastAddress': broadcastAddress,
      'port': port,
      'type': type,
    };
  }
}
