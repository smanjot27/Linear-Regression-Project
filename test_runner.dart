import 'dart:io';

/// A simple test runner script to run all tests
/// Usage: dart test_runner.dart
void main() async {
  print('🧪 Running Flutter Widget Tests...\n');
  
  final testFiles = [
    'test/widget_test.dart',
    'test/image_dialog_test.dart',
    'test/golden_test.dart',
  ];
  
  for (final testFile in testFiles) {
    print('📝 Running $testFile...');
    
    final result = await Process.run(
      'flutter',
      ['test', testFile, '--coverage'],
      workingDirectory: '.',
    );
    
    if (result.exitCode == 0) {
      print('✅ $testFile passed\n');
    } else {
      print('❌ $testFile failed');
      print('Error: ${result.stderr}');
      print('Output: ${result.stdout}\n');
    }
  }
  
  print('🎯 Test run completed!');
  print('💡 To run tests manually:');
  print('   flutter test');
  print('   flutter test --coverage');
  print('   flutter test test/widget_test.dart');
}