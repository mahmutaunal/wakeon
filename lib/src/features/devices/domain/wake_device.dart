import 'wake_device_type.dart';
import 'device_connection_status.dart';

/// Represents a Wake-on-LAN target device stored by the application.
class WakeDevice {
  final WakeDeviceType type;
  final String id;
  final String name;
  final String macAddress;
  final String broadcastAddress;
  final int port;
  final DateTime createdAt;
  final DateTime? lastWakeAt;
  final bool isFavorite;
  final DeviceConnectionStatus connectionStatus;
  final DateTime? lastSeenAt;
  final String? hostAddress;

  const WakeDevice({
    required this.type,
    required this.id,
    required this.name,
    required this.macAddress,
    required this.broadcastAddress,
    required this.port,
    required this.createdAt,
    this.lastWakeAt,
    this.isFavorite = false,
    this.connectionStatus = DeviceConnectionStatus.unknown,
    this.lastSeenAt,
    this.hostAddress,
  });

  /// Creates a modified copy of this device instance.
  WakeDevice copyWith({
    WakeDeviceType? type,
    String? id,
    String? name,
    String? macAddress,
    String? broadcastAddress,
    int? port,
    DateTime? createdAt,
    DateTime? lastWakeAt,
    bool clearLastWakeAt = false,
    bool? isFavorite,
    DeviceConnectionStatus? connectionStatus,
    DateTime? lastSeenAt,
    bool clearLastSeenAt = false,
    String? hostAddress,
    bool clearHostAddress = false,
  }) {
    return WakeDevice(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      macAddress: macAddress ?? this.macAddress,
      broadcastAddress: broadcastAddress ?? this.broadcastAddress,
      port: port ?? this.port,
      createdAt: createdAt ?? this.createdAt,
      // Allow explicitly clearing the last wake timestamp.
      lastWakeAt: clearLastWakeAt ? null : lastWakeAt ?? this.lastWakeAt,
      isFavorite: isFavorite ?? this.isFavorite,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastSeenAt: clearLastSeenAt ? null : lastSeenAt ?? this.lastSeenAt,
      hostAddress: clearHostAddress ? null : hostAddress ?? this.hostAddress,
    );
  }

  /// Creates a device instance from persisted JSON data.
  factory WakeDevice.fromJson(Map<String, dynamic> json) {
    return WakeDevice(
      type: WakeDeviceType.fromStorageValue(json['type'] as String?),
      id: json['id'] as String,
      name: json['name'] as String,
      macAddress: json['macAddress'] as String,
      broadcastAddress: json['broadcastAddress'] as String,
      port: json['port'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastWakeAt: json['lastWakeAt'] == null
          ? null
          : DateTime.parse(json['lastWakeAt'] as String),
      isFavorite: json['isFavorite'] as bool? ?? false,
      connectionStatus: DeviceConnectionStatus.unknown,
      lastSeenAt: json['lastSeenAt'] == null
          ? null
          : DateTime.parse(json['lastSeenAt'] as String),
      hostAddress: (json['hostAddress'] as String?)?.trim().isEmpty == true
          ? null
          : json['hostAddress'] as String?,
    );
  }

  /// Converts this device into a JSON-serializable representation.
  Map<String, dynamic> toJson() {
    return {
      'type': type.storageValue,
      'id': id,
      'name': name,
      'macAddress': macAddress,
      'broadcastAddress': broadcastAddress,
      'port': port,
      'createdAt': createdAt.toIso8601String(),
      'lastWakeAt': lastWakeAt?.toIso8601String(),
      'isFavorite': isFavorite,
      'lastSeenAt': lastSeenAt?.toIso8601String(),
      'hostAddress': hostAddress,
    };
  }
}
