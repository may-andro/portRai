import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/testimonial/domain/exception/testimonial_exception.dart';

void main() {
  group('TestimonialException', () {
    test('should only include the type when cause is null', () {
      const exception = TestimonialNotFoundException();

      expect(exception.toString(), 'TestimonialException');
    });

    test('should include the cause when provided', () {
      const exception = TestimonialNotFoundException(cause: 'missing');

      expect(exception.toString(), 'TestimonialException | Cause: missing');
    });

    test('should include the stack trace when provided', () {
      final stackTrace = StackTrace.current;
      final exception = TestimonialParsingException(
        cause: 'bad json',
        stackTrace: stackTrace,
      );

      expect(
        exception.toString(),
        'TestimonialException | Cause: bad json\nStackTrace: $stackTrace',
      );
    });

    test('should carry the provided cause for every subtype', () {
      expect(
        const TestimonialNotFoundException(cause: 'missing').cause,
        'missing',
      );
      expect(
        const TestimonialNetworkException(cause: 'timeout').cause,
        'timeout',
      );
      expect(
        const TestimonialUnauthorizedException(cause: 'forbidden').cause,
        'forbidden',
      );
      expect(
        const TestimonialCacheException(cause: 'cache error').cause,
        'cache error',
      );
    });
  });
}
