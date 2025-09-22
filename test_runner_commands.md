# Flutter Test Commands and Setup

## Initial Setup Commands

### 1. Add test dependencies to pubspec.yaml
```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  build_runner: ^2.4.7
  integration_test:
    sdk: flutter
```

### 2. Get dependencies
```bash
flutter pub get
```

### 3. Generate mock files (if using @GenerateMocks annotation)
```bash
flutter packages pub run build_runner build
```

## Running Tests

### Basic Test Commands
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/authentication/screens/login_screen_test.dart

# Run tests in a specific directory
flutter test test/authentication/

# Run tests with verbose output
flutter test --verbose

# Run tests and watch for changes
flutter test --watch
```

### Coverage Commands
```bash
# Run tests with coverage
flutter test --coverage

# Generate HTML coverage report (requires lcov)
# On macOS: brew install lcov
# On Ubuntu: sudo apt-get install lcov
genhtml coverage/lcov.info -o coverage/html

# Open coverage report
open coverage/html/index.html  # macOS
xdg-open coverage/html/index.html  # Linux
```

### Integration Test Commands
```bash
# Run integration tests on connected device
flutter test integration_test/

# Run integration tests with specific device
flutter test integration_test/ -d <device_id>

# List available devices
flutter devices
```

### Advanced Test Options
```bash
# Run tests with custom timeout
flutter test --timeout=60s

# Run tests with specific tags
flutter test --tags slow

# Run tests excluding specific tags
flutter test --exclude-tags integration

# Run tests with custom reporter
flutter test --reporter=json

# Run tests in release mode
flutter test --release
```

## IDE Integration

### VS Code
1. Install Flutter extension
2. Open test file
3. Click "Run" above test functions
4. Use Command Palette: `Flutter: Run Tests`

### Android Studio/IntelliJ
1. Install Flutter plugin
2. Right-click test file → Run
3. Use gutter icons to run individual tests
4. View results in Test Runner window

### Debugging Tests
```bash
# Debug specific test
flutter test --start-paused test/authentication/screens/login_screen_test.dart

# Then connect debugger to the observatory URL shown
```

## Test File Structure Commands

### Create test directory structure
```bash
mkdir -p test/authentication/screens
mkdir -p test/mocks
mkdir -p test/test_utils
mkdir -p integration_test
```

### Generate mock files
```bash
# After adding @GenerateMocks annotations
flutter packages pub run build_runner build

# Watch for changes and regenerate
flutter packages pub run build_runner watch

# Clean and rebuild
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Continuous Integration Setup

### GitHub Actions Example
Create `.github/workflows/test.yml`:
```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: flutter pub get
      - run: flutter test --coverage
      - uses: codecov/codecov-action@v3
```

### Running Tests in Docker
```dockerfile
FROM cirrusci/flutter:stable

COPY . /app
WORKDIR /app

RUN flutter pub get
RUN flutter test
```

## Performance Testing Commands
```bash
# Profile test performance
flutter test --profile

# Run tests with memory profiling
flutter test --enable-vmservice

# Benchmark widget tests
flutter test --benchmark
```

## Common Test Patterns Commands

### Create test template
```bash
# Create a basic test file template
cat > test/new_widget_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Widget Name Tests', () {
    setUp(() {
      // Setup before each test
    });

    testWidgets('should do something', (WidgetTester tester) async {
      // Arrange
      
      // Act
      
      // Assert
    });

    tearDown(() {
      // Cleanup after each test
    });
  });
}
EOF
```

## Troubleshooting Commands

### Clear Flutter cache
```bash
flutter clean
flutter pub get
```

### Reset test environment
```bash
flutter clean
rm -rf .dart_tool/
flutter pub get
flutter packages pub run build_runner clean
flutter packages pub run build_runner build
```

### Check Flutter doctor for test issues
```bash
flutter doctor -v
```

### Verify test setup
```bash
flutter test --dry-run
```

## Test Configuration Files

### Create test configuration file
Create `test/flutter_test_config.dart`:
```dart
import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  setUpAll(() {
    // Global test setup
  });

  tearDownAll(() {
    // Global test cleanup
  });

  await testMain();
}
```

### Create analysis options for tests
Create `analysis_options.yaml`:
```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  exclude:
    - "**/*.g.dart"
    - "**/*.freezed.dart"
    - "**/*.mocks.dart"

linter:
  rules:
    avoid_print: false
    prefer_const_constructors: false
```

## Quick Start Checklist

1. ✅ Add test dependencies to `pubspec.yaml`
2. ✅ Run `flutter pub get`
3. ✅ Create test directory structure
4. ✅ Write your first test
5. ✅ Run `flutter test` to verify setup
6. ✅ Generate mocks with `build_runner` if needed
7. ✅ Set up coverage reporting
8. ✅ Configure CI/CD pipeline

## Useful Test Snippets

### Widget Test Template
```bash
# Create widget test template
cat > test_template.dart << 'EOF'
testWidgets('description', (WidgetTester tester) async {
  // Arrange
  await tester.pumpWidget(MyWidget());
  
  // Act
  await tester.tap(find.text('Button'));
  await tester.pump();
  
  // Assert
  expect(find.text('Result'), findsOneWidget);
});
EOF
```

This comprehensive setup guide should get you started with Flutter widget testing efficiently!