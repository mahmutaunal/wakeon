import 'package:flutter_test/flutter_test.dart';
import 'package:wakeon/src/app/wakeon_app.dart';

void main() {
  testWidgets('Wakeon app starts successfully', (tester) async {
    await tester.pumpWidget(const WakeonApp());

    expect(find.byType(WakeonApp), findsOneWidget);
  });
}
