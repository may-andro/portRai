import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/portfolio/domain/exception/portfolio_exception.dart';

void main() {
  group('PortfolioException', () {
    test('should only include the type when cause is null', () {
      const exception = PortfolioNotFoundException();

      expect(exception.toString(), 'PortfolioNotFoundException');
    });

    test('should include the cause when provided', () {
      const exception = PortfolioNetworkException(cause: 'timeout');

      expect(
        exception.toString(),
        'PortfolioNetworkException | Cause: timeout',
      );
    });

    test('should include the stack trace when provided', () {
      final stackTrace = StackTrace.current;
      final exception = PortfolioParsingException(
        cause: 'bad payload',
        stackTrace: stackTrace,
      );

      expect(
        exception.toString(),
        'PortfolioParsingException | Cause: bad payload\nStackTrace: $stackTrace',
      );
    });

    test('should carry the provided cause for every subtype', () {
      expect(
        const PortfolioUnauthorizedException(cause: 'forbidden').cause,
        'forbidden',
      );
      expect(
        const PortfolioNotFoundException(cause: 'missing').cause,
        'missing',
      );
    });
  });
}
