
import 'dart:io';

import 'package:in_app_update/in_app_update.dart';

enum PlayUpdateResult { upToDate, updateStarted, updateDownloaded, unavailable, failed }

class PlayUpdateService {
  Future<PlayUpdateResult> checkForUpdate({bool userInitiated = false}) async {
    if (!Platform.isAndroid) return PlayUpdateResult.unavailable;
    try {
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
    } catch (_) {
      return PlayUpdateResult.failed;
    }
  }
}
