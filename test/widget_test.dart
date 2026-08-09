import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakeon/src/app/wakeon_app.dart';
import 'package:wakeon/src/core/settings/app_settings.dart';

void main() {
  testWidgets('Wakeon app starts successfully', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [sharedPreferencesProvider.overrideWithValue(preferences)],
        child: const WakeonApp(),
      ),
    );

    expect(find.byType(WakeonApp), findsOneWidget);
  });
}
