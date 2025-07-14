import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:loyalty_program_app/core/custom_exceptions.dart';
import 'package:loyalty_program_app/gst_verificattion/gst_verification_provider.dart';
import 'package:loyalty_program_app/gst_verificattion/repository_impl.dart';

import 'gst_verification_provider_test.mocks.dart';

// Generate mock classes
@GenerateMocks([GstVerificationRepositoryImpl])
void main() {
  group('GstVerificationProvider', () {
    late GstVerificationProvider provider;
    late MockGstVerificationRepositoryImpl mockRepository;

    setUp(() {
      mockRepository = MockGstVerificationRepositoryImpl();
      provider = GstVerificationProvider(repository: mockRepository);
    });

    group('Constructor', () {
      test('should initialize with provided repository', () {
        final provider = GstVerificationProvider(repository: mockRepository);
        expect(provider, isNotNull);
      });

      test('should create default repository when none provided', () {
        final provider = GstVerificationProvider();
        expect(provider, isNotNull);
      });
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(provider.isLoading, false);
        expect(provider.errorMessage, null);
        expect(provider.gstData, null);
      });
    });

    group('verifyGST', () {
      const testGstNumber = '07AAGFF2194N1Z1';
      const testGstData = {
        'gstin': '07AAGFF2194N1Z1',
        'lgnm': 'Test Company',
        'tradeNam': 'Test Trade Name',
        'sts': 'Active'
      };

      test('should successfully verify GST and update state', () async {
        // Arrange
        when(mockRepository.verifyGst(testGstNumber))
            .thenAnswer((_) async => testGstData);

        final List<bool> loadingStates = [];
        provider.addListener(() {
          loadingStates.add(provider.isLoading);
        });

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, null);
        expect(provider.gstData, testGstData);
        expect(loadingStates, [true, false]); // Should be true during loading, then false
        verify(mockRepository.verifyGst(testGstNumber)).called(1);
      });

      test('should handle NoInternetException', () async {
        // Arrange
        const exception = NoInternetException('No internet connection');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        final List<bool> loadingStates = [];
        final List<String?> errorStates = [];
        provider.addListener(() {
          loadingStates.add(provider.isLoading);
          errorStates.add(provider.errorMessage);
        });

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'No internet connection');
        expect(provider.gstData, null);
        expect(loadingStates, [true, false, false]);
        expect(errorStates, [null, 'No internet connection', 'No internet connection']);
      });

      test('should handle TimeoutAppException', () async {
        // Arrange
        const exception = TimeoutAppException('Request timeout');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'Request timeout');
        expect(provider.gstData, null);
      });

      test('should handle ApiException', () async {
        // Arrange
        const exception = ApiException('API error occurred');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'API error occurred');
        expect(provider.gstData, null);
      });

      test('should handle LocalDatabaseException', () async {
        // Arrange
        const exception = LocalDatabaseException('Database error');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'Unable to load data from your device. Please try again later.');
        expect(provider.gstData, null);
      });

      test('should handle InvalidGSTException', () async {
        // Arrange
        const exception = InvalidGSTException('Invalid GST number');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'Invalid GST number');
        expect(provider.gstData, null);
      });

      test('should handle generic exceptions', () async {
        // Arrange
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(Exception('Unknown error'));

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.errorMessage, 'Something went wrong');
        expect(provider.gstData, null);
      });

      test('should clear error message before new verification', () async {
        // Arrange
        const exception = NoInternetException('No internet');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        // Set initial error state
        await provider.verifyGST(testGstNumber);
        expect(provider.errorMessage, 'No internet');

        // Setup successful call
        when(mockRepository.verifyGst(testGstNumber))
            .thenAnswer((_) async => testGstData);

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.errorMessage, null);
        expect(provider.gstData, testGstData);
      });

      test('should notify listeners during state changes', () async {
        // Arrange
        when(mockRepository.verifyGst(testGstNumber))
            .thenAnswer((_) async => testGstData);

        int notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        // Should notify: 1) loading starts, 2) loading ends + data updated
        expect(notificationCount, 2);
      });

      test('should notify listeners on error', () async {
        // Arrange
        const exception = NoInternetException('No internet');
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(exception);

        int notificationCount = 0;
        provider.addListener(() {
          notificationCount++;
        });

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        // Should notify: 1) loading starts, 2) error + loading ends
        expect(notificationCount, 2);
      });

      test('should set loading to false even when exception occurs', () async {
        // Arrange
        when(mockRepository.verifyGst(testGstNumber))
            .thenThrow(Exception('Test exception'));

        // Act
        await provider.verifyGST(testGstNumber);

        // Assert
        expect(provider.isLoading, false);
      });

      test('should handle multiple concurrent verifications correctly', () async {
        // Arrange
        when(mockRepository.verifyGst(testGstNumber))
            .thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 100));
          return testGstData;
        });

        // Act - Start multiple verifications
        final futures = [
          provider.verifyGST(testGstNumber),
          provider.verifyGST(testGstNumber),
          provider.verifyGST(testGstNumber),
        ];

        await Future.wait(futures);

        // Assert
        expect(provider.isLoading, false);
        expect(provider.gstData, testGstData);
        expect(provider.errorMessage, null);
        // Verify repository was called multiple times
        verify(mockRepository.verifyGst(testGstNumber)).called(3);
      });
    });

    group('State Management', () {
      test('should preserve gstData from previous successful verification on error', () async {
        const testGstNumber1 = '07AAGFF2194N1Z1';
        const testGstNumber2 = '27AAGFF2194N1Z2';
        
        // First successful verification
        when(mockRepository.verifyGst(testGstNumber1))
            .thenAnswer((_) async => testGstData);
        
        await provider.verifyGST(testGstNumber1);
        expect(provider.gstData, testGstData);

        // Second verification fails
        when(mockRepository.verifyGst(testGstNumber2))
            .thenThrow(NoInternetException('No internet'));

        await provider.verifyGST(testGstNumber2);

        // Assert that gstData is preserved (not cleared on error)
        expect(provider.gstData, testGstData);
        expect(provider.errorMessage, 'No internet');
      });
    });
  });
}