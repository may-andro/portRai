import 'package:core/core.dart';

sealed class PortfolioException implements AppException {
  const PortfolioException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;
}

class PortfolioNotFoundException extends PortfolioException {
  const PortfolioNotFoundException({super.cause, super.stackTrace});

  @override
  String toString() {
    var result = 'PortfolioNotFoundException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class PortfolioNetworkException extends PortfolioException {
  const PortfolioNetworkException({super.cause, super.stackTrace});

  @override
  String toString() {
    var result = 'PortfolioNetworkException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class PortfolioParsingException extends PortfolioException {
  const PortfolioParsingException({super.cause, super.stackTrace});

  @override
  String toString() {
    var result = 'PortfolioParsingException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

class PortfolioUnauthorizedException extends PortfolioException {
  const PortfolioUnauthorizedException({super.cause, super.stackTrace});

  @override
  String toString() {
    var result = 'PortfolioUnauthorizedException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}
