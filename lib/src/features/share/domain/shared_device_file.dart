/// Represents the encrypted file structure used for device sharing.
class SharedDeviceFile {
  final int version;
  final int createdAt;
  final int? expiresAt;

  final String salt;
  final String nonce;
  final String cipherText;

  const SharedDeviceFile({
    required this.version,
    required this.createdAt,
    required this.salt,
    required this.nonce,
    required this.cipherText,
    this.expiresAt,
  });

  /// Creates an instance from a serialized share file.
  factory SharedDeviceFile.fromJson(Map<String, dynamic> json) {
    return SharedDeviceFile(
      version: json['version'] as int,
      createdAt: json['createdAt'] as int,
      expiresAt: json['expiresAt'] as int?,
      salt: json['salt'] as String,
      nonce: json['nonce'] as String,
      cipherText: json['cipherText'] as String,
    );
  }

  /// Converts this share file into a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'createdAt': createdAt,
      'expiresAt': expiresAt,
      'salt': salt,
      'nonce': nonce,
      'cipherText': cipherText,
    };
  }
}
