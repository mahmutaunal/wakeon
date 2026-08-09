import 'package:flutter_test/flutter_test.dart';
import 'package:wakeon/src/core/play/play_update_service.dart';

void main() {
  test('compares semantic store versions component by component', () {
    expect(PlayUpdateService.compareVersions('1.2.0', '1.1.9'), isPositive);
    expect(PlayUpdateService.compareVersions('1.2', '1.2.0'), isZero);
    expect(PlayUpdateService.compareVersions('1.2.0', '2.0.0'), isNegative);
  });
}
