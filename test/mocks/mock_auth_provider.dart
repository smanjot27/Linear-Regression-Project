import 'package:mockito/mockito.dart';
import 'package:loyalty_program_app/authentication/auth_provider.dart';

// Manual mock for AuthenticationProvider
class MockAuthenticationProvider extends Mock implements AuthenticationProvider {
  bool _isLoading = false;
  AuthenticationStatus _status = AuthenticationStatus.initial;
  String? _errorMessage;

  @override
  bool get isLoading => _isLoading;

  @override
  AuthenticationStatus get status => _status;

  @override
  String? get errorMessage => _errorMessage;

  // Helper methods for testing
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setStatus(AuthenticationStatus status) {
    _status = status;
    notifyListeners();
  }

  void setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void reset() {
    _isLoading = false;
    _status = AuthenticationStatus.initial;
    _errorMessage = null;
  }
}

// Mock for Constants if needed
class MockConstants {
  static const String PROJECT_NAME = "TEST_APP";
  static final RegExp phoneNumberRegex = RegExp(r'^[0-9]{10}$');
  
  // Mock analytics service
  static final MockAnalyticsService analyticsService = MockAnalyticsService();
  
  // Mock logger
  static final MockLogger logger = MockLogger();
}

class MockAnalyticsService extends Mock {
  void logScreenView(String screenName) {}
  void logDataVerified(String data) {}
  void logDataNotVerified(String data) {}
  void logSendOTP() {}
  void logOtpFailed() {}
}

class MockLogger extends Mock {
  void i(String tag, [String? message]) {}
}

// Helper function to mask string (from your original code)
String maskString(String input) {
  if (input.length <= 4) return input;
  return input.substring(0, 2) + '*' * (input.length - 4) + input.substring(input.length - 2);
}