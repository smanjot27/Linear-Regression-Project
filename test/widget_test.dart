import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  group('MyApp Widget Tests', () {
    testWidgets('MyApp creates MaterialApp with correct properties', (WidgetTester tester) async {
      // Build the app
      await tester.pumpWidget(const MyApp());

      // Verify that MaterialApp is created
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Verify that HomePage is the home widget
      expect(find.byType(HomePage), findsOneWidget);
      
      // Verify debug banner is disabled
      final MaterialApp materialApp = tester.widget(find.byType(MaterialApp));
      expect(materialApp.debugShowCheckedModeBanner, false);
    });
  });

  group('HomePage Widget Tests', () {
    testWidgets('HomePage displays correct title and button', (WidgetTester tester) async {
      // Build the HomePage widget
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify that the AppBar title is displayed correctly
      expect(find.text('Custom UI Application'), findsOneWidget);
      
      // Verify that the AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify that the ElevatedButton exists
      expect(find.byType(ElevatedButton), findsOneWidget);
      
      // Verify that the button text is correct
      expect(find.text('Show Image Dialog'), findsOneWidget);
      
      // Verify that the button is centered
      expect(find.byType(Center), findsOneWidget);
    });

    testWidgets('HomePage has correct widget structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify the main structure: Scaffold -> AppBar + Body
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      
      // Verify the body structure: Center -> ElevatedButton
      final Center centerWidget = tester.widget(find.byType(Center));
      expect(centerWidget.child, isA<ElevatedButton>());
    });

  });

  group('Basic Dialog Tests', () {
    testWidgets('Button tap opens dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify dialog is not initially present
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Image Preview'), findsNothing);

      // Tap the button to show dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Image Preview'), findsOneWidget);
    });

    testWidgets('Close button dismisses dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Close'), findsOneWidget);

      // Tap the Close button
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Image Preview'), findsNothing);
      
      // Verify we're back to the main screen
      expect(find.text('Show Image Dialog'), findsOneWidget);
    });

    testWidgets('Dialog can be dismissed by tapping outside', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify dialog is open
      expect(find.byType(AlertDialog), findsOneWidget);

      // Tap outside the dialog (on the barrier)
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      // Verify dialog is dismissed
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Integration Tests', () {
    testWidgets('Full user flow: open dialog, close dialog, repeat', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Initial state verification
      expect(find.text('Custom UI Application'), findsOneWidget);
      expect(find.text('Show Image Dialog'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);

      // First dialog open
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);

      // Second dialog open
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);

      // Close by tapping outside
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('App navigation and state consistency', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Verify initial app state
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.text('Custom UI Application'), findsOneWidget);

      // Interact with dialog
      await tester.tap(find.text('Show Image Dialog'));
      await tester.pumpAndSettle();
      
      // Verify dialog state doesn't affect main app structure
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);

      // Close and verify state restoration
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      expect(find.byType(MyApp), findsOneWidget);
      expect(find.byType(HomePage), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Accessibility Tests', () {
    testWidgets('Button has correct semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Verify button is accessible
      expect(find.bySemanticsLabel('Show Image Dialog'), findsOneWidget);
      
      // Verify button can be activated via semantics
      await tester.tap(find.bySemanticsLabel('Show Image Dialog'));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Dialog close button has correct semantics', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify close button is accessible
      expect(find.bySemanticsLabel('Close'), findsOneWidget);
      
      // Verify close button can be activated via semantics
      await tester.tap(find.bySemanticsLabel('Close'));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsNothing);
    });
  });

  group('Edge Cases and Error Handling', () {
    testWidgets('Multiple rapid button taps do not cause issues', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Rapidly tap the button multiple times
      for (int i = 0; i < 5; i++) {
        await tester.tap(find.byType(ElevatedButton));
        await tester.pump(const Duration(milliseconds: 50));
      }
      
      await tester.pumpAndSettle();

      // Should only have one dialog open
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Dialog handles rebuild correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Trigger rebuild
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );
      await tester.pumpAndSettle();

      // Dialog should still be present
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // Should still be able to close
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}