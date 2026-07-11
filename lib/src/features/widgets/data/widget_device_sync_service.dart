import 'dart:io';

import 'package:flutter/services.dart';

import '../../devices/domain/wake_device.dart';

/// Keeps native Android/iOS widgets in sync with the locally stored devices.
///
/// Widgets run outside the Flutter process, so they cannot safely read the
/// app's Dart-only SharedPreferences format directly. This service publishes a
/// small, stable snapshot that native widget code can read without depending on
/// UI state or Flutter initialization.
class WidgetDeviceSyncService {
  static const MethodChannel _channel = MethodChannel(
    'com.alpwarestudio.wakeon/widget',
  );

  const WidgetDeviceSyncService();

  /// Publishes the latest selectable device list to native widget storage.
  ///
  /// This method is intentionally best-effort. Device persistence must never
  /// fail just because a launcher/widget process is temporarily unavailable.
  Future<void> syncDevices(List<WakeDevice> devices) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return;
    }

    final payload = devices
        .map(
          (device) => <String, Object?>{
            'id': device.id,
            'name': device.name,
            'type': device.type.storageValue,
            'macAddress': device.macAddress,
            'broadcastAddress': device.broadcastAddress,
            'port': device.port,
            'isFavorite': device.isFavorite,
          },
        )
        .toList(growable: false);

    try {
      await _channel.invokeMethod<void>('syncWidgetDevices', payload);
    } on MissingPluginException {
      // Desktop/web/test runners do not expose the native channel.
    } on PlatformException {
      // Keep the main app resilient. Widget sync can be retried on next launch
      // or the next device mutation.
    }
  }
}
