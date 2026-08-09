import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'play_review_service.dart';
import 'play_update_service.dart';

final playReviewServiceProvider = Provider<PlayReviewService>(
  (_) => PlayReviewService(),
);

final playUpdateServiceProvider = Provider<PlayUpdateService>(
  (_) => PlayUpdateService(),
);

final appVersionProvider = FutureProvider<String>((_) async {
  final info = await PackageInfo.fromPlatform();
  return info.version;
});
