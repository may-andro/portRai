import 'package:error_reporter/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/error_reporter/app_fatal_exception_handler.dart';

void main() {
  group('AppFatalErrorHandler', () {
    late AppFatalErrorHandler handler;

    setUp(() {
      handler = AppFatalErrorHandler();
    });

    test('should implement FatalErrorHandler when instantiated', () {
      expect(handler, isA<FatalErrorHandler>());
    });

    // NOTE: onFatalError calls dart:io exit(1), which terminates the entire
    // test process. It is intentionally not invoked here — doing so would
    // kill the test runner instead of failing the test.
  });
}
