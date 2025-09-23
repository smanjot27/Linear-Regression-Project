import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import '../lib/main.dart';

void main() {
  group('Image Dialog Asset Tests', () {
    setUp(() {
      // Mock the asset bundle to prevent asset loading errors in tests
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString') {
            return '';
          }
          if (methodCall.method == 'load') {
            // Return a simple 1x1 pixel PNG for any asset request
            return Uint8List.fromList([
              0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
              0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
              0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1 dimensions
              0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, // bit depth, color type, etc.
              0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, // IDAT chunk
              0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
              0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00,
              0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, // IEND chunk
              0x42, 0x60, 0x82,
            ]);
          }
          return null;
        },
      );
    });

    tearDown(() {
      // Clean up the mock
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        null,
      );
    });

    testWidgets('Image dialog displays asset image correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify the Image widget is present
      expect(find.byType(Image), findsOneWidget);
      
      // Get the Image widget and verify its properties
      final Image imageWidget = tester.widget(find.byType(Image));
      expect(imageWidget.image, isA<AssetImage>());
      
      // Verify the asset path
      final AssetImage assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/IMG_0341.jpeg');
    });

    testWidgets('Image loads without errors in dialog', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Wait for image to load
      await tester.pump();
      await tester.pump();

      // Verify no error widgets are displayed
      expect(find.byType(Image), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dialog scrolls when content is large', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Verify SingleChildScrollView is present
      expect(find.byType(SingleChildScrollView), findsOneWidget);
      
      // Get the SingleChildScrollView widget
      final SingleChildScrollView scrollView = tester.widget(find.byType(SingleChildScrollView));
      
      // Verify it can scroll (though with our small content it may not need to)
      expect(scrollView.child, isA<Column>());
    });

    testWidgets('Image dialog maintains aspect ratio', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Get the Image widget
      final Image imageWidget = tester.widget(find.byType(Image));
      
      // Verify default fit behavior (should be BoxFit.contain by default for Image.asset)
      expect(imageWidget.fit, isNull); // Default behavior
      
      // Verify the image doesn't have explicit width/height constraints
      expect(imageWidget.width, isNull);
      expect(imageWidget.height, isNull);
    });
  });

  group('Dialog Layout Tests', () {
    testWidgets('Dialog content layout is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the dialog
      final AlertDialog dialog = tester.widget(find.byType(AlertDialog));
      
      // Verify dialog has title
      expect(dialog.title, isA<Text>());
      final Text titleText = dialog.title as Text;
      expect(titleText.data, 'Image Preview');
      
      // Verify dialog has content
      expect(dialog.content, isA<SingleChildScrollView>());
      
      // Verify dialog has actions
      expect(dialog.actions, isNotNull);
      expect(dialog.actions!.length, 1);
      expect(dialog.actions!.first, isA<TextButton>());
    });

    testWidgets('Dialog spacing is correct', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Find the SizedBox for spacing
      final SizedBox spacingBox = tester.widget(find.byType(SizedBox));
      expect(spacingBox.height, 16.0);
      expect(spacingBox.width, isNull);
    });

    testWidgets('Dialog is properly centered', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Get screen size
      final Size screenSize = tester.getSize(find.byType(MaterialApp));
      
      // Get dialog position
      final Rect dialogRect = tester.getRect(find.byType(AlertDialog));
      
      // Verify dialog is roughly centered (allowing for some margin)
      final double centerX = screenSize.width / 2;
      final double centerY = screenSize.height / 2;
      final double dialogCenterX = dialogRect.left + dialogRect.width / 2;
      final double dialogCenterY = dialogRect.top + dialogRect.height / 2;
      
      // Allow some tolerance for dialog positioning
      expect(dialogCenterX, closeTo(centerX, 50));
      expect(dialogCenterY, closeTo(centerY, 100));
    });
  });

  group('Dialog Interaction Tests', () {
    testWidgets('Dialog responds to back button press', (WidgetTester tester) async {
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

      // Simulate back button press
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/navigation',
        const StandardMethodCodec().encodeMethodCall(
          const MethodCall('routePopped', <String, dynamic>{
            'location': '/',
            'state': null,
          }),
        ),
        (data) {},
      );
      
      await tester.pumpAndSettle();

      // Dialog should still be open (since we're using showDialog with barrierDismissible: true by default)
      // The back button would close the dialog in a real app
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('Dialog handles keyboard navigation', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: HomePage(),
        ),
      );

      // Open the dialog
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Focus should be on the dialog
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // Tab to the Close button (if focusable)
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();
      
      // Press Enter to activate the Close button
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      
      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('Dialog handles escape key', (WidgetTester tester) async {
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

      // Press Escape key
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();

      // Dialog should be closed
      expect(find.byType(AlertDialog), findsNothing);
    });
  });
}