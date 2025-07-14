import 'package:flutter_test/flutter_test.dart';
import 'package:loyalty_program_app/core/custom_exceptions.dart';

/// Common test utilities for GST Verification Provider tests
class TestHelpers {
  /// Sample valid GST numbers for testing
  static const validGstNumbers = [
    '07AAGFF2194N1Z1',
    '27AAGFF2194N1Z2',
    '09AAGFF2194N1Z3',
  ];

  /// Sample invalid GST numbers for testing
  static const invalidGstNumbers = [
    'INVALID123',
    '12345',
    '',
    'ABC123DEF456',
  ];

  /// Sample GST data response
  static const sampleGstData = {
    'gstin': '07AAGFF2194N1Z1',
    'lgnm': 'Test Company Private Limited',
    'tradeNam': 'Test Trade Name',
    'sts': 'Active',
    'rgdt': '2017-07-01',
    'dty': 'Regular',
    'cxdt': '',
    'pradr': {
      'addr': {
        'bnm': 'Test Building',
        'st': 'Test Street',
        'loc': 'Test Location',
        'bno': '123',
        'stcd': 'Test State',
        'city': 'Test City',
        'flno': 'Ground Floor',
        'lt': '',
        'pncd': '110001'
      }
    }
  };

  /// Creates a list of all custom exceptions for comprehensive testing
  static List<Exception> getAllCustomExceptions() {
    return [
      const NoInternetException('No internet connection available'),
      const TimeoutAppException('Request timeout occurred'),
      const ApiException('API server error occurred'),
      const LocalDatabaseException('Local database error occurred'),
      const InvalidGSTException('Invalid GST number provided'),
    ];
  }

  /// Helper to verify listener notification count
  static void verifyListenerNotifications({
    required void Function() action,
    required int expectedNotifications,
    required void Function() addListener,
  }) {
    int notificationCount = 0;
    addListener(() {
      notificationCount++;
    });

    action();

    expect(notificationCount, expectedNotifications);
  }

  /// Helper to create test timeout duration
  static Duration get testTimeout => const Duration(seconds: 5);

  /// Helper to create short delay for async operations
  static Duration get shortDelay => const Duration(milliseconds: 100);

  /// Helper to create longer delay for timeout simulations
  static Duration get longDelay => const Duration(seconds: 2);
}

/// Extension methods for better test readability
extension GstVerificationTestExtensions on String {
  /// Checks if the string is a valid GST number format
  bool get isValidGstFormat {
    final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z]{1}[0-9A-Z]{1}$');
    return gstRegex.hasMatch(this);
  }
}

/// Test data builder for creating various test scenarios
class GstTestDataBuilder {
  Map<String, dynamic> _data = Map.from(TestHelpers.sampleGstData);

  /// Sets the GST number
  GstTestDataBuilder withGstin(String gstin) {
    _data['gstin'] = gstin;
    return this;
  }

  /// Sets the legal name
  GstTestDataBuilder withLegalName(String legalName) {
    _data['lgnm'] = legalName;
    return this;
  }

  /// Sets the trade name
  GstTestDataBuilder withTradeName(String tradeName) {
    _data['tradeNam'] = tradeName;
    return this;
  }

  /// Sets the status
  GstTestDataBuilder withStatus(String status) {
    _data['sts'] = status;
    return this;
  }

  /// Sets the registration date
  GstTestDataBuilder withRegistrationDate(String regDate) {
    _data['rgdt'] = regDate;
    return this;
  }

  /// Builds the test data
  Map<String, dynamic> build() {
    return Map.from(_data);
  }

  /// Creates a builder with empty data
  static GstTestDataBuilder empty() {
    final builder = GstTestDataBuilder();
    builder._data = {};
    return builder;
  }

  /// Creates a builder with minimal valid data
  static GstTestDataBuilder minimal() {
    final builder = GstTestDataBuilder();
    builder._data = {
      'gstin': '07AAGFF2194N1Z1',
      'lgnm': 'Test Company',
      'sts': 'Active'
    };
    return builder;
  }
}