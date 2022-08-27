import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:encore_game_sheet/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('column: ', () {
    testWidgets('tap on column header, points should change',
        (WidgetTester tester) async {
      // Load app
      app.main();

      await tester.pumpAndSettle();

      // Verify the column does exist
      expect(find.text("H"), findsOneWidget);

      // Verify the current possible score for H is 1
      var scoreH = find.text("1");
      expect(scoreH, findsOneWidget);

      var scoreHeval = scoreH.evaluate();
      expect((scoreHeval.first.widget as Text).data, "1");

      // Finds the column to tap on
      final Finder headerH = find.text("H");

      // Emulate a tap on the floating action button.
      await tester.tap(headerH);

      // Trigger a frame.
      await tester.pumpAndSettle();

      // Verify the new possible score for H is 0
      expect((scoreHeval.first.widget as Text).data, "0");
    });
  });
}
