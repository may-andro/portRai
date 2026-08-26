import 'package:error_reporter/error_reporter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/error_reporter/app_blacklist_error_handler.dart';
import 'package:portrai/src/error_reporter/blacklist_exception.dart';

class _OtherException implements Exception {}

void main() {
  group('AppBlacklistErrorHandler', () {
    late AppBlacklistErrorHandler handler;

    setUp(() {
      handler = AppBlacklistErrorHandler();
    });

    test('should implement BlacklistErrorHandler when instantiated', () {
      expect(handler, isA<BlacklistErrorHandler>());
    });

    test('should return true when isBlacklistError is called with BlacklistException', () {
      final result = handler.isBlacklistError(BlacklistException());

      expect(result, isTrue);
    });

    test('should return false when isBlacklistError is called with a different exception', () {
      final result = handler.isBlacklistError(_OtherException());

      expect(result, isFalse);
    });

    test('should return false when isBlacklistError is called with a plain object', () {
      final result = handler.isBlacklistError(Object());

      expect(result, isFalse);
    });
  });
}
