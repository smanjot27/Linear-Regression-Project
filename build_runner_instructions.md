# GST Verification Provider Unit Tests

## Setup Instructions

### 1. Add Required Dependencies

Add these dependencies to your `pubspec.yaml` file:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
```

### 2. Generate Mock Classes

Before running the tests, you need to generate the mock classes:

```bash
flutter packages pub run build_runner build
```

This will generate the `gst_verification_provider_test.mocks.dart` file that contains the mock implementations.

### 3. Run the Tests

```bash
flutter test test/gst_verification_provider_test.dart
```

Or to run all tests:

```bash
flutter test
```

## Test Coverage

The unit tests cover the following scenarios:

### Constructor Tests
- ✅ Initialization with provided repository
- ✅ Initialization with default repository

### Initial State Tests  
- ✅ Correct initial values for all properties

### GST Verification Tests
- ✅ Successful GST verification
- ✅ NoInternetException handling
- ✅ TimeoutAppException handling  
- ✅ ApiException handling
- ✅ LocalDatabaseException handling
- ✅ InvalidGSTException handling
- ✅ Generic exception handling
- ✅ Error message clearing on new verification
- ✅ Listener notifications during state changes
- ✅ Loading state management
- ✅ Concurrent verification handling

### State Management Tests
- ✅ Data preservation across error states

## Mock Objects

The tests use Mockito to mock the `GstVerificationRepositoryImpl` dependency, allowing for isolated testing of the provider logic without external dependencies.

## Continuous Integration

For CI/CD pipelines, ensure that mock generation is included:

```bash
flutter packages pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
flutter test
```