import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Creates temporary files used by device export and sharing flows.
class DeviceShareFileService {
  const DeviceShareFileService();

  /// Writes [content] to a temporary file with the provided [fileName].
  Future<File> createFile({
    required String fileName,
    required String content,
  }) async {
    final tempDir = await getTemporaryDirectory();

    final file = File('${tempDir.path}/$fileName');

    return file.writeAsString(content, flush: true);
  }
}
