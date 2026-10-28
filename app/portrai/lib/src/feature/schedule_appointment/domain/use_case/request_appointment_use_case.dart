import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/exception/_exception.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RequestAppointmentFailure extends BasicFailure {
  const RequestAppointmentFailure({super.cause});
}

@Localizable('errorAppointmentRequestMissingDetails')
class RequestAppointmentMissingDetailsFailure
    extends RequestAppointmentFailure {
  const RequestAppointmentMissingDetailsFailure({super.cause});
}

@Localizable('errorAppointmentRequestInvalidEmail')
class RequestAppointmentInvalidEmailFailure extends RequestAppointmentFailure {
  const RequestAppointmentInvalidEmailFailure({super.cause});
}

@Localizable('errorAppointmentRequestConsent')
class RequestAppointmentConsentMissingFailure
    extends RequestAppointmentFailure {
  const RequestAppointmentConsentMissingFailure({super.cause});
}

@Localizable('errorAppointmentSlotUnavailable')
class RequestAppointmentSlotUnavailableFailure
    extends RequestAppointmentFailure {
  const RequestAppointmentSlotUnavailableFailure({super.cause});
}

@Localizable('errorAppointmentRequestLimit')
class RequestAppointmentLimitFailure extends RequestAppointmentFailure {
  const RequestAppointmentLimitFailure({super.cause});
}

@Localizable('errorAppointmentRequestInvalid')
class RequestAppointmentInvalidFailure extends RequestAppointmentFailure {
  const RequestAppointmentInvalidFailure({super.cause});
}

@Localizable('errorScheduleAppointmentUnavailable')
class RequestAppointmentNotSetUpFailure extends RequestAppointmentFailure {
  const RequestAppointmentNotSetUpFailure({super.cause});
}

@Localizable('errorScheduleAppointmentNetwork')
class RequestAppointmentNetworkFailure extends RequestAppointmentFailure {
  const RequestAppointmentNetworkFailure({super.cause});
}

@Localizable('errorAppointmentRequestUnknown')
class RequestAppointmentUnknownFailure extends RequestAppointmentFailure {
  const RequestAppointmentUnknownFailure({super.cause});
}

class RequestAppointmentParam {
  const RequestAppointmentParam({
    required this.slotStart,
    required this.name,
    required this.email,
    required this.topic,
    required this.message,
    required this.hasAcceptedPrivacyPolicy,
  });

  final DateTime slotStart;
  final String name;
  final String email;
  final String topic;
  final String message;
  final bool hasAcceptedPrivacyPolicy;

  /// Use case params are logged, so this never prints the visitor's details.
  @override
  String toString() => 'RequestAppointmentParam(slotStart: $slotStart)';
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Books a slot for the visitor and returns the request's ID. The owner then
/// accepts or declines it, and the visitor hears back by email.
@register
class RequestAppointmentUseCase
    extends
        BaseUseCase<
          String,
          RequestAppointmentParam,
          RequestAppointmentFailure
        > {
  RequestAppointmentUseCase(this._scheduleAppointmentRepository);

  final ScheduleAppointmentRepository _scheduleAppointmentRepository;

  @protected
  @override
  FutureOr<Either<RequestAppointmentFailure, String>> execute(
    RequestAppointmentParam param,
  ) async {
    final name = param.name.trim();
    final email = param.email.trim();
    final topic = param.topic.trim();
    final message = param.message.trim();
    if (name.isEmpty || email.isEmpty || topic.isEmpty || message.isEmpty) {
      return const Left(RequestAppointmentMissingDetailsFailure());
    }
    if (!_emailPattern.hasMatch(email)) {
      return const Left(RequestAppointmentInvalidEmailFailure());
    }
    if (!param.hasAcceptedPrivacyPolicy) {
      return const Left(RequestAppointmentConsentMissingFailure());
    }

    final requestId = await _scheduleAppointmentRepository.requestAppointment(
      AppointmentRequestEntity(
        slotStart: param.slotStart,
        name: name,
        email: email,
        topic: topic,
        message: message,
      ),
    );
    return Right(requestId);
  }

  @protected
  @override
  RequestAppointmentFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AppointmentSlotUnavailableException() =>
      RequestAppointmentSlotUnavailableFailure(cause: error),
    AppointmentRequestLimitException() => RequestAppointmentLimitFailure(
      cause: error,
    ),
    AppointmentRequestInvalidException() => RequestAppointmentInvalidFailure(
      cause: error,
    ),
    ScheduleAppointmentNotSetUpException() => RequestAppointmentNotSetUpFailure(
      cause: error,
    ),
    ScheduleAppointmentNetworkException() => RequestAppointmentNetworkFailure(
      cause: error,
    ),
    _ => RequestAppointmentUnknownFailure(cause: error),
  };
}
