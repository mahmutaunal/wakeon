import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

import '../../devices/domain/wake_device.dart';
import '../domain/share_expiry.dart';
import '../domain/shared_device_file.dart';
import '../domain/shared_device_payload.dart';
import 'device_share_file_service.dart';
import 'device_share_service.dart';
import 'shared_device_mapper.dart';

/// Coordinates device sharing and import workflows.
class DeviceShareManager {
  final DeviceShareService shareService;
  final DeviceShareFileService fileService;
  final SharedDeviceMapper mapper;

  const DeviceShareManager({
    required this.shareService,
    required this.fileService,
    required this.mapper,
  });

  /// Creates a protected share file, invokes the platform share sheet,
  /// and returns the generated share code.
  Future<String> shareDevice(WakeDevice device) async {
    final payload = mapper.fromDevice(device);

    final result = await shareService.createShareFile(
      payload: payload,
      expiry: ShareExpiry.oneDay,
    );

    final file = await fileService.createFile(
      fileName: result.fileName,
      content: result.fileContent,
    );

    await SharePlus.instance.share(ShareParams(files: [XFile(file.path)]));

    return result.shareCode;
  }

  /// Lets the user select a shared device file and decrypts its payload
  /// using the provided share code.
  Future<SharedDevicePayload?> pickAndDecryptSharedDevice({
    required String shareCode,
  }) async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: 'Import Wakeon device',
      type: FileType.custom,
      allowedExtensions: ['wakeon'],
      allowMultiple: false,
      withData: true,
    );

    final selectedFile = result?.files.single;

    if (selectedFile == null) {
      return null;
    }

    final bytes = selectedFile.bytes;

    if (bytes == null) {
      throw const FormatException('invalid_share_file');
    }

    final rawValue = utf8.decode(bytes);
    final decodedValue = jsonDecode(rawValue);

    if (decodedValue is! Map<String, dynamic>) {
      throw const FormatException('invalid_share_file');
    }

    final sharedFile = SharedDeviceFile.fromJson(decodedValue);

    return shareService.decryptPayload(
      file: sharedFile,
      shareCode: shareCode.trim(),
    );
  }
}
