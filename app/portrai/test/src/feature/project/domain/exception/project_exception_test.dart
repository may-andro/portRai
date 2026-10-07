import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/domain/exception/project_exception.dart';

void main() {
  group('ProjectException', () {
    test('should only include the type when cause is null', () {
      const exception = ProjectNotFoundException();

      expect(exception.toString(), 'ProjectException');
    });

    test('should include the cause when provided', () {
      const exception = ProjectNotFoundException(cause: 'not found');

      expect(exception.toString(), 'ProjectException | Cause: not found');
    });

    test('should include the stack trace when provided', () {
      final stackTrace = StackTrace.current;
      final exception = ProjectParsingException(
        cause: 'bad json',
        stackTrace: stackTrace,
      );

      expect(
        exception.toString(),
        'ProjectException | Cause: bad json\nStackTrace: $stackTrace',
      );
    });

    test('should carry the provided cause for every subtype', () {
      expect(const ProjectNotFoundException(cause: 'missing').cause, 'missing');
      expect(const ProjectNetworkException(cause: 'timeout').cause, 'timeout');
      expect(
        const ProjectUnauthorizedException(cause: 'forbidden').cause,
        'forbidden',
      );
      expect(
        const ProjectCacheException(cause: 'cache error').cause,
        'cache error',
      );
    });
  });
}
