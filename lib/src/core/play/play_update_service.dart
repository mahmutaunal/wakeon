import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum PlayUpdateResult {
  upToDate,
  updateStarted,
  updateDownloaded,
  unavailable,
  failed,
}

/// Coordinates store-native update flows without requiring a private backend.
///
/// Android uses Google Play Core. iOS discovers the public App Store record by
/// bundle ID and presents it inside the app with `SKStoreProductViewController`.
class PlayUpdateService {
  PlayUpdateService({HttpClient? httpClient, MethodChannel? appStoreChannel})
    : _httpClient = httpClient ?? HttpClient(),
      _appStoreChannel =
          appStoreChannel ?? const MethodChannel(_appStoreChannelName);

  static const _appStoreChannelName = 'com.alpwarestudio.wakeon/app_store';
  static const _lastAutomaticCheckKey = 'update_last_automatic_check_at';
  static const _automaticCheckInterval = Duration(hours: 24);

  final HttpClient _httpClient;
  final MethodChannel _appStoreChannel;

  Future<PlayUpdateResult> checkForUpdate({bool userInitiated = false}) async {
    if (!Platform.isAndroid && !Platform.isIOS) {
      return PlayUpdateResult.unavailable;
    }

    if (!userInitiated && !await _automaticCheckIsDue()) {
      return PlayUpdateResult.upToDate;
    }

    try {
      if (!userInitiated) await _recordAutomaticCheck();
      return Platform.isAndroid ? _checkAndroid() : _checkIos();
    } catch (_) {
      return PlayUpdateResult.failed;
    }
  }

  Future<PlayUpdateResult> _checkAndroid() async {
    final info = await InAppUpdate.checkForUpdate();
    if (info.updateAvailability != UpdateAvailability.updateAvailable) {
      return PlayUpdateResult.upToDate;
    }

    final shouldUseImmediate =
        info.immediateUpdateAllowed &&
        (info.updatePriority >= 4 ||
            (info.clientVersionStalenessDays ?? 0) >= 7);

    if (shouldUseImmediate) {
      await InAppUpdate.performImmediateUpdate();
      return PlayUpdateResult.updateStarted;
    }

    if (info.flexibleUpdateAllowed) {
      final result = await InAppUpdate.startFlexibleUpdate();
      if (result == AppUpdateResult.success) {
        await InAppUpdate.completeFlexibleUpdate();
        return PlayUpdateResult.updateDownloaded;
      }
      return PlayUpdateResult.failed;
    }

    return PlayUpdateResult.unavailable;
  }

  Future<PlayUpdateResult> _checkIos() async {
    final packageInfo = await PackageInfo.fromPlatform();
    final storeApp = await _lookupIosApp(packageInfo.packageName);
    if (storeApp == null) return PlayUpdateResult.unavailable;

    if (compareVersions(storeApp.version, packageInfo.version) <= 0) {
      return PlayUpdateResult.upToDate;
    }

    final presented = await _appStoreChannel.invokeMethod<bool>(
      'showStoreProduct',
      <String, Object>{'appStoreId': storeApp.trackId},
    );
    return presented == true
        ? PlayUpdateResult.updateStarted
        : PlayUpdateResult.failed;
  }

  Future<_IosStoreApp?> _lookupIosApp(String bundleId) async {
    final uri = Uri.https('itunes.apple.com', '/lookup', {
      'bundleId': bundleId,
      'entity': 'software',
    });
    final request = await _httpClient.getUrl(uri);
    final response = await request.close();
    if (response.statusCode != HttpStatus.ok) return null;

    final body = await response.transform(utf8.decoder).join();
    final json = jsonDecode(body) as Map<String, dynamic>;
    final results = json['results'] as List<dynamic>?;
    if (results == null || results.isEmpty) return null;

    final app = results.first as Map<String, dynamic>;
    final trackId = app['trackId'];
    final version = app['version'];
    if (trackId is! int || version is! String) return null;
    return _IosStoreApp(trackId: trackId, version: version);
  }

  Future<bool> _automaticCheckIsDue() async {
    final preferences = await SharedPreferences.getInstance();
    final lastCheck = DateTime.tryParse(
      preferences.getString(_lastAutomaticCheckKey) ?? '',
    );
    return lastCheck == null ||
        DateTime.now().difference(lastCheck) >= _automaticCheckInterval;
  }

  Future<void> _recordAutomaticCheck() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _lastAutomaticCheckKey,
      DateTime.now().toIso8601String(),
    );
  }

  /// Compares dotted store versions without adding another versioning package.
  static int compareVersions(String left, String right) {
    final leftParts = _numericVersionParts(left);
    final rightParts = _numericVersionParts(right);
    final length = leftParts.length > rightParts.length
        ? leftParts.length
        : rightParts.length;
    for (var index = 0; index < length; index++) {
      final leftPart = index < leftParts.length ? leftParts[index] : 0;
      final rightPart = index < rightParts.length ? rightParts[index] : 0;
      if (leftPart != rightPart) return leftPart.compareTo(rightPart);
    }
    return 0;
  }

  static List<int> _numericVersionParts(String value) {
    return value
        .split('.')
        .map(
          (part) => int.tryParse(RegExp(r'^\d+').stringMatch(part) ?? '') ?? 0,
        )
        .toList();
  }
}

class _IosStoreApp {
  const _IosStoreApp({required this.trackId, required this.version});

  final int trackId;
  final String version;
}
