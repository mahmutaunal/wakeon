/// Represents the generated output required to share a device.
class DeviceShareResult {
  final String shareCode;
  final String fileName;
  final String fileContent;

  const DeviceShareResult({
    required this.shareCode,
    required this.fileName,
    required this.fileContent,
  });
}
