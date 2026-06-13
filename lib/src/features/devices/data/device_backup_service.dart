import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

import '../domain/wake_device.dart';

/// Handles importing and exporting device backups as JSON files.
class DeviceBackupService {
  const DeviceBackupService();

  /// Exports all configured devices to a user-selected JSON file.
  Future<bool> exportDevices(List<WakeDevice> devices) async {
    if (devices.isEmpty) {
      throw const FormatException('There are no devices to export.');
    }

    final now = DateTime.now();
    final fileName =
        'wakeon_backup_${now.year}_${_twoDigits(now.month)}_${_twoDigits(now.day)}_${_twoDigits(now.hour)}_${_twoDigits(now.minute)}.json';

    // Store metadata to support future backup format migrations.
    final backup = {
      'app': 'Wakeon',
      'schemaVersion': 1,
      'exportedAt': now.toIso8601String(),
      'deviceCount': devices.length,
      'devices': devices.map((device) => device.toJson()).toList(),
    };

    final jsonValue = const JsonEncoder.withIndent('  ').convert(backup);

    final savedPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Export Wakeon backup',
      fileName: fileName,
      type: FileType.custom,
      allowedExtensions: ['json'],
      bytes: utf8.encode(jsonValue),
    );

    return savedPath != null;
  }

  /// Imports devices from a previously exported Wakeon backup file.
  Future<List<WakeDevice>> importDevices() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Wakeon backup',
      type: FileType.custom,
      allowedExtensions: ['json'],
      allowMultiple: false,
      withData: true,
    );

    final selectedFile = result?.files.single;

    if (selectedFile == null) {
      return [];
    }

    final bytes = selectedFile.bytes;

    final rawValue = bytes != null
        ? utf8.decode(bytes)
        : await File(selectedFile.path!).readAsString();

    final decodedValue = jsonDecode(rawValue);

    if (decodedValue is! Map<String, dynamic>) {
      throw const FormatException('Invalid Wakeon backup file.');
    }

    if (decodedValue['app'] != 'Wakeon') {
      throw const FormatException('This is not a Wakeon backup file.');
    }

    final schemaVersion = decodedValue['schemaVersion'];

    // Reject unsupported backup formats to avoid data inconsistencies.
    if (schemaVersion != 1) {
      throw FormatException('Unsupported backup version: $schemaVersion');
    }

    final rawDevices = decodedValue['devices'];

    if (rawDevices is! List) {
      throw const FormatException('Backup file does not contain devices.');
    }

    final devices = <WakeDevice>[];

    for (final rawDevice in rawDevices) {
      if (rawDevice is! Map<String, dynamic>) {
        continue;
      }

      try {
        devices.add(WakeDevice.fromJson(rawDevice));
      } catch (_) {
        continue;
      }
    }

    return devices;
  }

  // Formats date and time components for backup file names.
  String _twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }
}
