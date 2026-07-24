
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'play_review_service.dart';
import 'play_update_service.dart';

final playReviewServiceProvider = Provider<PlayReviewService>(
  (_) => PlayReviewService(),
);

final playUpdateServiceProvider = Provider<PlayUpdateService>(
  (_) => PlayUpdateService(),
);
