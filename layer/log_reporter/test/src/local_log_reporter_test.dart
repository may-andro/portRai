import 'package:flutter_test/flutter_test.dart';
import 'package:log_reporter/src/log/local_log_reporter.dart';
import 'package:logger/logger.dart';
import 'package:mocktail/mocktail.dart';

class _MockLogger extends Mock implements Logger {}

void main() {
  group(LocalLogReporter, () {
    late LocalLogReporter localLogReporter;
    late _MockLogger mockLogger;

    setUp(() {
      mockLogger = _MockLogger();
      localLogReporter = LocalLogReporter(mockLogger);
    });

    group('debug', () {
      test('should delegate to logger.d with message and tag', () {
        localLogReporter.debug('test message', tag: 'TAG');

        verify(
          () => mockLogger.d('TAG: test message'),
        ).called(1);
      });

      test('should pass error and stacktrace to logger.d', () {
        final error = Exception('oops');
        final stack = StackTrace.current;

        localLogReporter.debug(
          'msg',
          tag: 'T',
          error: error,
          stacktrace: stack,
        );

        verify(
          () => mockLogger.d('T: msg', error: error, stackTrace: stack),
        ).called(1);
      });

      test('should handle null tag', () {
        localLogReporter.debug('msg');

        verify(
          () => mockLogger.d('null: msg'),
        ).called(1);
      });
    });

    group('error', () {
      test('should delegate to logger.e with message and tag', () {
        localLogReporter.error('error message', tag: 'ERR');

        verify(
          () => mockLogger.e('ERR: error message'),
        ).called(1);
      });

      test('should pass error and stacktrace to logger.e', () {
        final error = Exception('fail');
        final stack = StackTrace.current;

        localLogReporter.error(
          'msg',
          tag: 'T',
          error: error,
          stacktrace: stack,
        );

        verify(
          () => mockLogger.e('T: msg', error: error, stackTrace: stack),
        ).called(1);
      });
    });
  });
}
