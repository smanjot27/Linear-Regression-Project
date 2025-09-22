import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:loyalty_program_app/authentication/auth_provider.dart';
import 'package:loyalty_program_app/authentication/screens/login_screen.dart';
import '../mocks/mock_auth_provider.dart';

/// Utility class for common widget testing operations
class WidgetTestUtils {
  
  /// Creates a MaterialApp wrapper with the LoginScreen and mock provider
  static Widget createTestableLoginScreen({
    MockAuthenticationProvider? mockAuthProvider,
    ThemeData? theme,
  }) {
    final provider = mockAuthProvider ?? MockAuthenticationProvider();
    
    return MaterialApp(
      theme: theme ?? ThemeData.light(),
      home: ChangeNotifierProvider<AuthenticationProvider>(
        create: (_) => provider,
        child: const LoginScreen(),
      ),
    );
  }

  /// Sets up mock method channel for asset loading (privacy policy)
  static void setupMockAssetChannel(WidgetTester tester, {String? policyText}) {
    const String defaultPolicyText = '''
Privacy Policy

This is a mock privacy policy for testing purposes.

1. Data Collection
We collect information you provide directly to us.

2. Data Usage  
We use your information to provide our services.

3. Data Sharing
We do not share your personal information with third parties.

4. Contact Us
If you have questions, contact us at privacy@example.com.
    ''';

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter/assets'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'loadString' && 
            methodCall.arguments == 'assets/legal/privacy_policy.txt') {
          return policyText ?? defaultPolicyText;
        }
        return null;
      },
    );
  }

  /// Helper to find widgets by text with partial matching
  static Finder findTextContaining(String text) {
    return find.byWidgetPredicate((widget) {
      if (widget is Text) {
        return widget.data?.contains(text) == true;
      }
      if (widget is RichText) {
        return widget.text.toPlainText().contains(text);
      }
      return false;
    });
  }

  /// Helper to enter text in phone number field
  static Future<void> enterPhoneNumber(WidgetTester tester, String phoneNumber) async {
    final textField = find.byType(TextField);
    await tester.enterText(textField, phoneNumber);
    await tester.pump();
  }

  /// Helper to tap continue button
  static Future<void> tapContinueButton(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await tester.pump();
  }

  /// Helper to open privacy policy dialog
  static Future<void> openPrivacyPolicyDialog(WidgetTester tester) async {
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  /// Helper to close dialogs
  static Future<void> closeDialog(WidgetTester tester) async {
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle(const Duration(milliseconds: 300));
  }

  /// Helper to verify phone number format
  static bool isValidPhoneFormat(String phone) {
    return RegExp(r'^\+91\d{10}$').hasMatch(phone);
  }

  /// Helper to simulate loading state
  static void simulateLoading(MockAuthenticationProvider mockProvider) {
    mockProvider.setLoading(true);
  }

  /// Helper to simulate success state
  static void simulateSuccess(MockAuthenticationProvider mockProvider) {
    mockProvider.setLoading(false);
    mockProvider.setStatus(AuthenticationStatus.success);
    mockProvider.setErrorMessage(null);
  }

  /// Helper to simulate error state
  static void simulateError(MockAuthenticationProvider mockProvider, String errorMessage) {
    mockProvider.setLoading(false);
    mockProvider.setStatus(AuthenticationStatus.error);
    mockProvider.setErrorMessage(errorMessage);
  }

  /// Helper to reset provider to initial state
  static void resetProvider(MockAuthenticationProvider mockProvider) {
    mockProvider.reset();
  }
}

/// Custom matchers for better test assertions
class CustomMatchers {
  /// Matcher to check if a phone number has correct format
  static Matcher hasValidPhoneFormat() {
    return predicate<String>((phone) => WidgetTestUtils.isValidPhoneFormat(phone), 'has valid phone format');
  }

  /// Matcher to check if text field has specific input formatters
  static Matcher hasInputFormatter<T>() {
    return predicate<TextField>((textField) {
      return textField.inputFormatters?.any((formatter) => formatter is T) == true;
    }, 'has input formatter of type $T');
  }

  /// Matcher to check if widget has specific decoration
  static Matcher hasDecoration() {
    return predicate<TextField>((textField) {
      return textField.decoration != null;
    }, 'has decoration');
  }
}

/// Test data class for common test scenarios
class TestData {
  static const String validPhoneNumber = '9876543210';
  static const String invalidShortPhoneNumber = '123';
  static const String invalidLongPhoneNumber = '123456789012345';
  static const String nonNumericInput = 'abc123def';
  static const String expectedFormattedPhone = '+919876543210';
  
  static const String networkErrorMessage = 'Network connection failed';
  static const String invalidOtpErrorMessage = 'Invalid OTP entered';
  static const String serverErrorMessage = 'Server error occurred';
  
  static const List<String> validPhoneNumbers = [
    '9876543210',
    '8765432109',
    '7654321098',
    '9123456789',
  ];
  
  static const List<String> invalidPhoneNumbers = [
    '123',           // Too short
    '12345',         // Still too short
    'abc1234567',    // Contains letters
    '98765432101',   // Too long (but will be limited by formatter)
    '',              // Empty
  ];
}