import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/app_config/domain/exception/app_config_exception.dart';

void main() {
  group('AppConfigException', () {
    test('toString should only include the type when cause is null', () {
      const exception = AppConfigNotFoundException();

      expect(exception.toString(), 'AppConfigException');
    });

    test('toString should include the cause when provided', () {
      const exception = AppConfigNotFoundException(cause: 'not found');

      expect(exception.toString(), 'AppConfigException | Cause: not found');
    });

    test('toString should include the stack trace when provided', () {
      final stackTrace = StackTrace.current;
      final exception = AppConfigParsingException(
        cause: 'bad json',
        stackTrace: stackTrace,
      );

      expect(
        exception.toString(),
        'AppConfigException | Cause: bad json\nStackTrace: $stackTrace',
      );
    });

    test('AppConfigNotFoundException should carry its cause', () {
      const exception = AppConfigNotFoundException(cause: 'missing');

      expect(exception.cause, 'missing');
    });

    test('AppConfigNetworkException should carry its cause', () {
      const exception = AppConfigNetworkException(cause: 'timeout');

      expect(exception.cause, 'timeout');
    });

    test('AppConfigParsingException should carry its cause', () {
      const exception = AppConfigParsingException(cause: 'invalid json');

      expect(exception.cause, 'invalid json');
    });

    test('AppConfigUnauthorizedException should carry its cause', () {
      const exception = AppConfigUnauthorizedException(cause: 'forbidden');

      expect(exception.cause, 'forbidden');
    });

    test('AppConfigCacheException should carry its cause', () {
      const exception = AppConfigCacheException(cause: 'cache error');

      expect(exception.cause, 'cache error');
    });
  });
}
