import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  group('Golden Tests', () {
    testWidgets('HomePage golden test', (WidgetTester tester) async {
      // Set a consistent size for golden tests
      await tester.binding.setSurfaceSize(const Size(400, 600));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Compare with golden file
      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('golden/homepage.png'),
      );
    });

    testWidgets('Image dialog golden test', (WidgetTester tester) async {
      // Set a consistent size for golden tests
      await tester.binding.setSurfaceSize(const Size(400, 600));
      
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Compare with golden file
      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('golden/image_dialog.png'),
      );
    });

    testWidgets('HomePage with different theme golden test', (WidgetTester tester) async {
      // Set a consistent size for golden tests
      await tester.binding.setSurfaceSize(const Size(400, 600));
      
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: const HomePage(),
        ),
      );

      await tester.pumpAndSettle();

      // Compare with golden file for dark theme
      await expectLater(
        find.byType(HomePage),
        matchesGoldenFile('golden/homepage_dark.png'),
      );
    });
  });
}