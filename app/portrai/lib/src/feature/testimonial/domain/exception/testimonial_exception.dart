import 'package:core/core.dart';

sealed class TestimonialException implements AppException {
  const TestimonialException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'TestimonialException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class TestimonialNotFoundException extends TestimonialException {
  const TestimonialNotFoundException({super.cause, super.stackTrace});
}

class TestimonialNetworkException extends TestimonialException {
  const TestimonialNetworkException({super.cause, super.stackTrace});
}

class TestimonialParsingException extends TestimonialException {
  const TestimonialParsingException({super.cause, super.stackTrace});
}

class TestimonialUnauthorizedException extends TestimonialException {
  const TestimonialUnauthorizedException({super.cause, super.stackTrace});
}

class TestimonialCacheException extends TestimonialException {
  const TestimonialCacheException({super.cause, super.stackTrace});
}
