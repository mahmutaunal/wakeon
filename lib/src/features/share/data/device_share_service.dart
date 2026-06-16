import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../domain/share_expiry.dart';
import '../domain/shared_device_file.dart';
import '../domain/shared_device_payload.dart';
import '../domain/device_share_result.dart';

/// Encrypts and decrypts device share payloads using a short user-facing code.
class DeviceShareService {
  static const _version = 1;

  static final Random _random = Random.secure();

  DeviceShareService();

  /// Converts a device payload into an encrypted share file.
  Future<SharedDeviceFile> encryptPayload({
    required SharedDevicePayload payload,
    required String shareCode,
    required ShareExpiry expiry,
  }) async {
    final now = DateTime.now();

    final expiresAt = expiry.duration == null
        ? null
        : now.add(expiry.duration!).millisecondsSinceEpoch;

    final salt = _generateBytes(16);
    final nonce = _generateBytes(12);

    final secretKey = await _deriveKey(shareCode: shareCode, salt: salt);

    final algorithm = AesGcm.with256bits();

    final clearText = utf8.encode(jsonEncode(payload.toJson()));

    final secretBox = await algorithm.encrypt(
      clearText,
      secretKey: secretKey,
      nonce: nonce,
    );

    final cipherBytes = [...secretBox.cipherText, ...secretBox.mac.bytes];

    return SharedDeviceFile(
      version: _version,
      createdAt: now.millisecondsSinceEpoch,
      expiresAt: expiresAt,
      salt: base64Encode(salt),
      nonce: base64Encode(nonce),
      cipherText: base64Encode(cipherBytes),
    );
  }

  /// Restores an encrypted share file back into a device payload.
  Future<SharedDevicePayload> decryptPayload({
    required SharedDeviceFile file,
    required String shareCode,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    if (file.expiresAt != null && now > file.expiresAt!) {
      throw const FormatException('share_expired');
    }

    final salt = base64Decode(file.salt);
    final nonce = base64Decode(file.nonce);
    final cipherBytes = base64Decode(file.cipherText);

    if (cipherBytes.length < 16) {
      throw const FormatException('invalid_share_file');
    }

    final cipherText = cipherBytes.sublist(0, cipherBytes.length - 16);

    final mac = Mac(cipherBytes.sublist(cipherBytes.length - 16));

    final secretKey = await _deriveKey(shareCode: shareCode, salt: salt);

    final algorithm = AesGcm.with256bits();

    late final List<int> clearBytes;

    try {
      clearBytes = await algorithm.decrypt(
        SecretBox(cipherText, nonce: nonce, mac: mac),
        secretKey: secretKey,
      );
    } on SecretBoxAuthenticationError {
      throw const FormatException('invalid_share_code');
    } catch (_) {
      throw const FormatException('invalid_share_file');
    }

    final json = jsonDecode(utf8.decode(clearBytes)) as Map<String, dynamic>;

    return SharedDevicePayload.fromJson(json);
  }

  Future<SecretKey> _deriveKey({
    required String shareCode,
    required List<int> salt,
  }) async {
    final algorithm = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: 120000,
      bits: 256,
    );

    final normalizedShareCode = _normalizeShareCode(shareCode);

    return algorithm.deriveKey(
      secretKey: SecretKey(utf8.encode(normalizedShareCode)),
      nonce: salt,
    );
  }

  List<int> _generateBytes(int length) {
    return List.generate(length, (_) => _random.nextInt(256));
  }

  /// Generates the six-digit code required to decrypt a shared device file.
  String generateShareCode() {
    const digits = '0123456789';

    return List.generate(
      6,
      (_) => digits[_random.nextInt(digits.length)],
    ).join();
  }

  String buildFileName() {
    final now = DateTime.now();

    return 'wakeon_${now.millisecondsSinceEpoch}.wakeon';
  }

  /// Creates the encrypted file content and matching share code for a device.
  Future<DeviceShareResult> createShareFile({
    required SharedDevicePayload payload,
    required ShareExpiry expiry,
  }) async {
    final shareCode = generateShareCode();

    final encryptedFile = await encryptPayload(
      payload: payload,
      shareCode: shareCode,
      expiry: expiry,
    );

    return DeviceShareResult(
      shareCode: shareCode,
      fileName: buildFileName(),
      fileContent: jsonEncode(encryptedFile.toJson()),
    );
  }

  String _normalizeShareCode(String shareCode) {
    final normalized = shareCode.trim();

    if (!RegExp(r'^\d{6}$').hasMatch(normalized)) {
      throw const FormatException('invalid_share_code');
    }

    return normalized;
  }
}
