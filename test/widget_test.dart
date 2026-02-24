import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:convict_six_calisthenics_tracker/app.dart';
import 'package:convict_six_calisthenics_tracker/data/providers/app_providers.dart';

void main() {
  setUpAll(() async {
    // Mirror the initialisation done in main() so DateFormat('EEEE', 'zh_TW')
    // in HomeScreen does not throw during widget tests.
    await initializeDateFormatting('zh_TW', null);
  });

  testWidgets('app smoke test — renders without crashing', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const ConvictSixApp(),
      ),
    );

    // Verify the bottom navigation bar renders.
    expect(find.byType(BottomNavigationBar), findsOneWidget);
  });
}
