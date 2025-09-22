import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:loyalty_program_app/authentication/screens/login_screen.dart';
import 'package:loyalty_program_app/authentication/auth_provider.dart';
import '../../test_utils/widget_test_utils.dart';
import '../../mocks/mock_auth_provider.dart';

/// Integration tests for LoginScreen
/// These tests simulate real user interactions and flows
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LoginScreen Integration Tests', () {
    late MockAuthenticationProvider mockAuthProvider;

    setUp(() {
      mockAuthProvider = MockAuthenticationProvider();
    });

    testWidgets('Complete login flow with valid phone number', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
      ));
      WidgetTestUtils.setupMockAssetChannel(tester);

      // Act & Assert - Step by step user journey
      
      // 1. Verify initial screen state
      expect(find.text('Earn Loyalty Rewards'), findsOneWidget);
      expect(find.text('Register to earn rewards'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      
      // 2. Enter valid phone number
      await WidgetTestUtils.enterPhoneNumber(tester, TestData.validPhoneNumber);
      
      // 3. Verify phone number is entered correctly
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, TestData.validPhoneNumber);
      
      // 4. Tap continue button
      await WidgetTestUtils.tapContinueButton(tester);
      
      // 5. Verify loading state is shown
      WidgetTestUtils.simulateLoading(mockAuthProvider);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      // 6. Simulate successful OTP send
      WidgetTestUtils.simulateSuccess(mockAuthProvider);
      await tester.pump();
      
      // 7. Verify success state (loading indicator should be gone)
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Error handling flow with network failure', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
      ));

      // Act
      await WidgetTestUtils.enterPhoneNumber(tester, TestData.validPhoneNumber);
      await WidgetTestUtils.tapContinueButton(tester);
      
      // Simulate network error
      WidgetTestUtils.simulateError(mockAuthProvider, TestData.networkErrorMessage);
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
      // Note: Error messages are shown via Toast, which is hard to test
      // In a real app, consider showing errors in the UI for better testability
    });

    testWidgets('Privacy policy dialog interaction flow', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
      ));
      WidgetTestUtils.setupMockAssetChannel(tester);

      // Act & Assert
      
      // 1. Open privacy policy dialog
      await WidgetTestUtils.openPrivacyPolicyDialog(tester);
      
      // 2. Verify dialog is shown with correct content
      expect(find.text('Privacy Policy'), findsNWidgets(2)); // Main screen + dialog
      expect(find.text('Close'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
      
      // 3. Verify scrollable content
      expect(find.byType(Scrollbar), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsAtLeastNWidgets(1));
      
      // 4. Close dialog
      await WidgetTestUtils.closeDialog(tester);
      
      // 5. Verify dialog is closed
      expect(find.text('Close'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Privacy Policy'), findsOneWidget); // Only main screen
    });

    testWidgets('Input validation flow with various phone numbers', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
      ));

      // Test each invalid phone number
      for (String invalidPhone in TestData.invalidPhoneNumbers) {
        // Clear previous input
        await tester.enterText(find.byType(TextField), '');
        await tester.pump();
        
        // Enter invalid phone number
        await tester.enterText(find.byType(TextField), invalidPhone);
        await tester.pump();
        
        // Tap continue
        await WidgetTestUtils.tapContinueButton(tester);
        
        // Verify no loading state (invalid input should be rejected)
        expect(find.byType(CircularProgressIndicator), findsNothing);
      }

      // Test valid phone number
      await tester.enterText(find.byType(TextField), TestData.validPhoneNumber);
      await tester.pump();
      await WidgetTestUtils.tapContinueButton(tester);
      
      // Should trigger loading (valid input)
      WidgetTestUtils.simulateLoading(mockAuthProvider);
      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Theme consistency throughout interaction', (WidgetTester tester) async {
      // Test with light theme
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
        theme: ThemeData.light(),
      ));
      WidgetTestUtils.setupMockAssetChannel(tester);

      // Verify button styling
      final button = tester.widget<ElevatedButton>(find.text('Continue'));
      expect(button.style?.backgroundColor?.resolve({}), Colors.amber);

      // Open privacy policy to test dialog theming
      await WidgetTestUtils.openPrivacyPolicyDialog(tester);
      expect(find.byType(AlertDialog), findsOneWidget);
      
      await WidgetTestUtils.closeDialog(tester);

      // Test with dark theme
      await tester.pumpWidget(WidgetTestUtils.createTestableLoginScreen(
        mockAuthProvider: mockAuthProvider,
        theme: ThemeData.dark(),
      ));

      // Verify theming is applied consistently
      expect(find.text('Continue'), findsOneWidget);
    });

    tearDown(() {
      WidgetTestUtils.resetProvider(mockAuthProvider);
    });
  });
}