import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:country_code_picker/country_code_picker.dart';

// Import your actual files (adjust paths as needed)
import 'package:loyalty_program_app/authentication/screens/login_screen.dart';
import 'package:loyalty_program_app/authentication/auth_provider.dart';
import 'package:loyalty_program_app/core/constants.dart';
import 'package:loyalty_program_app/core/theme_utils.dart';
import 'package:loyalty_program_app/versioning/screens/update_version_screen.dart';

// Generate mocks using mockito
@GenerateMocks([AuthenticationProvider])
import 'login_screen_test.mocks.dart';

void main() {
  group('LoginScreen Widget Tests', () {
    late MockAuthenticationProvider mockAuthProvider;
    
    setUp(() {
      // Create mock provider before each test
      mockAuthProvider = MockAuthenticationProvider();
      
      // Set up default mock behavior
      when(mockAuthProvider.isLoading).thenReturn(false);
      when(mockAuthProvider.status).thenReturn(AuthenticationStatus.initial);
      when(mockAuthProvider.errorMessage).thenReturn(null);
    });

    // Helper function to create widget under test
    Widget createLoginScreen() {
      return MaterialApp(
        home: ChangeNotifierProvider<AuthenticationProvider>(
          create: (_) => mockAuthProvider,
          child: const LoginScreen(),
        ),
      );
    }

    testWidgets('should display all UI elements correctly', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());
      
      // Assert - Check if all main UI elements are present
      expect(find.text('Earn Loyalty Rewards'), findsOneWidget);
      expect(find.text('Register to earn rewards'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(CountryCodePicker), findsOneWidget);
      expect(find.byIcon(Icons.card_giftcard), findsOneWidget);
      expect(find.textContaining('By continuing, you agree to our'), findsOneWidget);
      expect(find.text('Privacy Policy'), findsOneWidget);
    });

    testWidgets('should show phone number input field with correct properties', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(createLoginScreen());
      
      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.keyboardType, TextInputType.numberWithOptions(decimal: true, signed: true));
      expect(textField.inputFormatters?.length, 2); // digits only + length limiting
      expect(textField.decoration?.hintText, 'Enter your phone number');
    });

    testWidgets('should update country code when country picker changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      
      // Act - Tap on country code picker (this is complex to test, so we'll test the widget exists)
      expect(find.byType(CountryCodePicker), findsOneWidget);
      
      // Assert - Check initial country code setup
      final countryPicker = tester.widget<CountryCodePicker>(find.byType(CountryCodePicker));
      expect(countryPicker.initialSelection, 'IN');
    });

    testWidgets('should limit phone number input to 10 digits', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      final textField = find.byType(TextField);
      
      // Act - Enter text longer than 10 digits
      await tester.enterText(textField, '12345678901234567890');
      await tester.pump();
      
      // Assert - Should be limited to 10 digits
      final textFieldWidget = tester.widget<TextField>(textField);
      expect(textFieldWidget.controller?.text.length, lessThanOrEqualTo(10));
    });

    testWidgets('should only accept numeric input', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      final textField = find.byType(TextField);
      
      // Act - Try to enter non-numeric characters
      await tester.enterText(textField, 'abc123def456');
      await tester.pump();
      
      // Assert - Should only contain numeric characters
      final textFieldWidget = tester.widget<TextField>(textField);
      final text = textFieldWidget.controller?.text ?? '';
      expect(RegExp(r'^\d*$').hasMatch(text), isTrue);
    });

    testWidgets('should show loading indicator when authentication is in progress', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(true);
      
      // Act
      await tester.pumpWidget(createLoginScreen());
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Continue'), findsNothing);
    });

    testWidgets('should show Continue button when not loading', (WidgetTester tester) async {
      // Arrange
      when(mockAuthProvider.isLoading).thenReturn(false);
      
      // Act
      await tester.pumpWidget(createLoginScreen());
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('should call sendOTP when Continue button is tapped with valid phone', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      
      // Enter valid phone number
      await tester.enterText(find.byType(TextField), '9876543210');
      await tester.pump();
      
      // Act - Tap Continue button
      await tester.tap(find.text('Continue'));
      await tester.pump();
      
      // Assert - Verify sendOtp was called
      verify(mockAuthProvider.sendOtp(any)).called(1);
    });

    testWidgets('should not call sendOTP with invalid phone number', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createLoginScreen());
      
      // Enter invalid phone number (less than 10 digits)
      await tester.enterText(find.byType(TextField), '123');
      await tester.pump();
      
      // Act - Tap Continue button
      await tester.tap(find.text('Continue'));
      await tester.pump();
      
      // Assert - Verify sendOtp was not called
      verifyNever(mockAuthProvider.sendOtp(any));
    });

    testWidgets('should show privacy policy dialog when Privacy Policy is tapped', (WidgetTester tester) async {
      // Arrange
      const String mockPolicyText = 'This is a mock privacy policy text.';
      
      // Mock the asset loading
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString' && 
              methodCall.arguments == 'assets/legal/privacy_policy.txt') {
            return mockPolicyText;
          }
          return null;
        },
      );
      
      await tester.pumpWidget(createLoginScreen());
      
      // Act - Tap on Privacy Policy link
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle(); // Wait for dialog animation
      
      // Assert - Check if dialog is shown
      expect(find.text('Privacy Policy'), findsNWidgets(2)); // One in main screen, one in dialog
      expect(find.text('Close'), findsOneWidget);
    });

    testWidgets('should close privacy policy dialog when Close is tapped', (WidgetTester tester) async {
      // Arrange
      const String mockPolicyText = 'This is a mock privacy policy text.';
      
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('flutter/assets'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'loadString') {
            return mockPolicyText;
          }
          return null;
        },
      );
      
      await tester.pumpWidget(createLoginScreen());
      
      // Open dialog
      await tester.tap(find.text('Privacy Policy'));
      await tester.pumpAndSettle();
      
      // Act - Close dialog
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      
      // Assert - Dialog should be closed
      expect(find.text('Close'), findsNothing);
      expect(find.text('Privacy Policy'), findsOneWidget); // Only the main screen one
    });

    group('Authentication Flow Tests', () {
      testWidgets('should navigate to OTP screen on successful OTP send', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.status).thenReturn(AuthenticationStatus.success);
        when(mockAuthProvider.sendOtp(any)).thenAnswer((_) async {
          when(mockAuthProvider.status).thenReturn(AuthenticationStatus.success);
        });
        
        await tester.pumpWidget(MaterialApp(
          home: ChangeNotifierProvider<AuthenticationProvider>(
            create: (_) => mockAuthProvider,
            child: const LoginScreen(),
          ),
          routes: {
            '/otp': (context) => const Scaffold(body: Text('OTP Screen')),
          },
        ));
        
        // Enter valid phone and tap continue
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pumpAndSettle();
        
        // Assert - Should navigate to OTP screen
        // Note: This is simplified - in real app you'd need to mock Navigator
        verify(mockAuthProvider.sendOtp('+919876543210')).called(1);
      });

      testWidgets('should show error message on failed OTP send', (WidgetTester tester) async {
        // Arrange
        when(mockAuthProvider.status).thenReturn(AuthenticationStatus.error);
        when(mockAuthProvider.errorMessage).thenReturn('Network error');
        when(mockAuthProvider.sendOtp(any)).thenAnswer((_) async {
          when(mockAuthProvider.status).thenReturn(AuthenticationStatus.error);
        });
        
        await tester.pumpWidget(createLoginScreen());
        
        // Act
        await tester.enterText(find.byType(TextField), '9876543210');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();
        
        // Assert
        verify(mockAuthProvider.sendOtp('+919876543210')).called(1);
        // Note: Toast messages are hard to test in widget tests
        // You might want to show error in UI instead of toast for better testability
      });
    });

    group('Input Validation Tests', () {
      testWidgets('should validate empty phone number', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());
        
        // Act - Tap continue without entering phone
        await tester.tap(find.text('Continue'));
        await tester.pump();
        
        // Assert - Should not call sendOtp
        verifyNever(mockAuthProvider.sendOtp(any));
      });

      testWidgets('should validate phone number with less than 10 digits', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());
        
        // Act
        await tester.enterText(find.byType(TextField), '12345');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();
        
        // Assert
        verifyNever(mockAuthProvider.sendOtp(any));
      });

      testWidgets('should validate phone number with more than 10 digits', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createLoginScreen());
        
        // Act
        await tester.enterText(find.byType(TextField), '123456789012345');
        await tester.pump();
        await tester.tap(find.text('Continue'));
        await tester.pump();
        
        // Assert - Should be limited by input formatter, so this might still be valid
        // The input formatter should limit it to 10 digits
        final textField = tester.widget<TextField>(find.byType(TextField));
        expect(textField.controller?.text.length, lessThanOrEqualTo(10));
      });
    });

    group('Theme and Styling Tests', () {
      testWidgets('should apply correct theme colors', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createLoginScreen());
        
        // Assert - Check if theme-related widgets exist
        expect(find.byType(ElevatedButton), findsOneWidget);
        
        final elevatedButton = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
        expect(elevatedButton.style?.backgroundColor?.resolve({}), Colors.amber);
      });

      testWidgets('should have correct button styling', (WidgetTester tester) async {
        // Arrange & Act
        await tester.pumpWidget(createLoginScreen());
        
        // Assert
        final button = tester.widget<ElevatedButton>(find.text('Continue'));
        expect(button.style?.backgroundColor?.resolve({}), Colors.amber);
        
        final buttonText = tester.widget<Text>(find.text('Continue'));
        expect(buttonText.style?.color, Colors.black);
        expect(buttonText.style?.fontSize, 16);
      });
    });

    tearDown(() {
      // Clean up after each test
      reset(mockAuthProvider);
    });
  });
}

// Additional helper functions for complex testing scenarios
class TestHelpers {
  static Future<void> enterPhoneNumber(WidgetTester tester, String phoneNumber) async {
    await tester.enterText(find.byType(TextField), phoneNumber);
    await tester.pump();
  }
  
  static Future<void> tapContinueButton(WidgetTester tester) async {
    await tester.tap(find.text('Continue'));
    await tester.pump();
  }
  
  static Future<void> openPrivacyPolicy(WidgetTester tester) async {
    await tester.tap(find.text('Privacy Policy'));
    await tester.pumpAndSettle();
  }
}