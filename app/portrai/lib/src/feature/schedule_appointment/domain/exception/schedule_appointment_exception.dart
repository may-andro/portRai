import 'package:core/core.dart';

sealed class ScheduleAppointmentException implements AppException {
  const ScheduleAppointmentException({this.cause, this.stackTrace});

  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() {
    var result = 'ScheduleAppointmentException';
    if (cause != null) result += ' | Cause: $cause';
    if (stackTrace != null) result += '\nStackTrace: $stackTrace';
    return result;
  }
}

/// Scheduling is not set up on the server, so no slot can be offered or taken.
class ScheduleAppointmentNotSetUpException
    extends ScheduleAppointmentException {
  const ScheduleAppointmentNotSetUpException({super.cause, super.stackTrace});
}

/// The slot is no longer free or was never offered.
class AppointmentSlotUnavailableException extends ScheduleAppointmentException {
  const AppointmentSlotUnavailableException({super.cause, super.stackTrace});
}

/// The visitor's address or the day has reached its number of requests.
class AppointmentRequestLimitException extends ScheduleAppointmentException {
  const AppointmentRequestLimitException({super.cause, super.stackTrace});
}

/// The server refused a field of the request, such as a text that is too long.
class AppointmentRequestInvalidException extends ScheduleAppointmentException {
  const AppointmentRequestInvalidException({super.cause, super.stackTrace});
}

class ScheduleAppointmentNetworkException extends ScheduleAppointmentException {
  const ScheduleAppointmentNetworkException({super.cause, super.stackTrace});
}

class ScheduleAppointmentUnknownException extends ScheduleAppointmentException {
  const ScheduleAppointmentUnknownException({super.cause, super.stackTrace});
}

/// The request is gone, for example because its retention ended.
class AppointmentRequestNotFoundException extends ScheduleAppointmentException {
  const AppointmentRequestNotFoundException({super.cause, super.stackTrace});
}

/// Firestore rules refused the read or the answer, for example for a request
/// that was already answered.
class AppointmentRequestPermissionDeniedException
    extends ScheduleAppointmentException {
  const AppointmentRequestPermissionDeniedException({
    super.cause,
    super.stackTrace,
  });
}
