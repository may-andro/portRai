import 'package:core/core.dart';

sealed class CallBookingException implements AppException {
  const CallBookingException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'CallBookingException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

/// Booking is not set up on the server, so no slot can be offered or taken.
class CallBookingNotSetUpException extends CallBookingException {
  const CallBookingNotSetUpException({super.cause, super.stackTrace});
}

/// The slot is no longer free or was never offered.
class CallSlotUnavailableException extends CallBookingException {
  const CallSlotUnavailableException({super.cause, super.stackTrace});
}

/// The visitor's address or the day has reached its number of requests.
class CallRequestLimitException extends CallBookingException {
  const CallRequestLimitException({super.cause, super.stackTrace});
}

/// The server refused a field of the request, such as a text that is too long.
class CallRequestInvalidException extends CallBookingException {
  const CallRequestInvalidException({super.cause, super.stackTrace});
}

class CallBookingNetworkException extends CallBookingException {
  const CallBookingNetworkException({super.cause, super.stackTrace});
}

class CallBookingUnknownException extends CallBookingException {
  const CallBookingUnknownException({super.cause, super.stackTrace});
}
