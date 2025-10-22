# Flutter Project Structure for GST Verification Tests

## Recommended Project Structure

```
loyalty_program_app/
├── lib/
│   ├── core/
│   │   ├── constants.dart
│   │   └── custom_exceptions.dart
│   ├── gst_verificattion/
│   │   ├── gst_verification_api.dart
│   │   ├── gst_verification_provider.dart
│   │   └── repository_impl.dart
│   └── main.dart
├── test/
│   ├── gst_verification/
│   │   ├── gst_verification_provider_test.dart
│   │   └── gst_verification_provider_test.mocks.dart (generated)
│   └── helpers/
│       └── test_helpers.dart
├── pubspec.yaml
└── README.md
```

## File Placement Instructions

### 1. Main Test File
- **Location**: `test/gst_verification/gst_verification_provider_test.dart`
- **Purpose**: Contains all unit tests for the GST verification provider

### 2. Test Helpers
- **Location**: `test/helpers/test_helpers.dart`
- **Purpose**: Common utilities, test data builders, and helper functions

### 3. Generated Mocks
- **Location**: `test/gst_verification/gst_verification_provider_test.mocks.dart`
- **Purpose**: Auto-generated mock classes (created by build_runner)
- **Note**: This file should be gitignored as it's generated

### 4. pubspec.yaml Dependencies

Add these to your `pubspec.yaml`:

```yaml
name: loyalty_program_app
description: A Flutter loyalty program app

dependencies:
  flutter:
    sdk: flutter
  # Your other dependencies...

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.2
  build_runner: ^2.4.7
  flutter_lints: ^3.0.0

flutter:
  uses-material-design: true
```

### 5. .gitignore Additions

Add these lines to your `.gitignore`:

```gitignore
# Generated mock files
*.mocks.dart

# Build runner outputs
*.g.dart
```

## Running Tests

From the project root directory:

```bash
# Install dependencies
flutter pub get

# Generate mocks
flutter packages pub run build_runner build

# Run specific test file
flutter test test/gst_verification/gst_verification_provider_test.dart

# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage
```

## Test Organization Tips

1. **Group Related Tests**: Use `group()` to organize related test cases
2. **Descriptive Names**: Use clear, descriptive names for test cases
3. **AAA Pattern**: Follow Arrange-Act-Assert pattern in tests
4. **Mock External Dependencies**: Use mocks for all external dependencies
5. **Test Edge Cases**: Include tests for error conditions and edge cases
6. **Verify State Changes**: Test that the provider state changes correctly
7. **Check Listener Notifications**: Ensure `notifyListeners()` is called appropriately

## Coverage Reports

To generate and view coverage reports:

```bash
# Generate coverage
flutter test --coverage

# Install lcov (on macOS)
brew install lcov

# Generate HTML report
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html
```