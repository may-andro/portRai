import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/domain/entity/_entity.dart';
import 'package:portrai/src/feature/call_booking/domain/exception/_exception.dart';
import 'package:portrai/src/feature/call_booking/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class RequestCallFailure extends BasicFailure {
  const RequestCallFailure({super.cause});
}

@Localizable('errorCallRequestMissingDetails')
class RequestCallMissingDetailsFailure extends RequestCallFailure {
  const RequestCallMissingDetailsFailure({super.cause});
}

@Localizable('errorCallRequestInvalidEmail')
class RequestCallInvalidEmailFailure extends RequestCallFailure {
  const RequestCallInvalidEmailFailure({super.cause});
}

@Localizable('errorCallRequestConsent')
class RequestCallConsentMissingFailure extends RequestCallFailure {
  const RequestCallConsentMissingFailure({super.cause});
}

@Localizable('errorCallSlotUnavailable')
class RequestCallSlotUnavailableFailure extends RequestCallFailure {
  const RequestCallSlotUnavailableFailure({super.cause});
}

@Localizable('errorCallRequestLimit')
class RequestCallLimitFailure extends RequestCallFailure {
  const RequestCallLimitFailure({super.cause});
}

@Localizable('errorCallRequestInvalid')
class RequestCallInvalidFailure extends RequestCallFailure {
  const RequestCallInvalidFailure({super.cause});
}

@Localizable('errorCallBookingUnavailable')
class RequestCallNotSetUpFailure extends RequestCallFailure {
  const RequestCallNotSetUpFailure({super.cause});
}

@Localizable('errorCallBookingNetwork')
class RequestCallNetworkFailure extends RequestCallFailure {
  const RequestCallNetworkFailure({super.cause});
}

@Localizable('errorCallRequestUnknown')
class RequestCallUnknownFailure extends RequestCallFailure {
  const RequestCallUnknownFailure({super.cause});
}

class RequestCallParam {
  const RequestCallParam({
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
  String toString() => 'RequestCallParam(slotStart: $slotStart)';
}

final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

/// Books a slot for the visitor and returns the request's ID. The owner then
/// accepts or declines it, and the visitor hears back by email.
@register
class RequestCallUseCase
    extends BaseUseCase<String, RequestCallParam, RequestCallFailure> {
  RequestCallUseCase(this._callBookingRepository);

  final CallBookingRepository _callBookingRepository;

  @protected
  @override
  FutureOr<Either<RequestCallFailure, String>> execute(
    RequestCallParam param,
  ) async {
    final name = param.name.trim();
    final email = param.email.trim();
    final topic = param.topic.trim();
    final message = param.message.trim();
    if (name.isEmpty || email.isEmpty || topic.isEmpty || message.isEmpty) {
      return const Left(RequestCallMissingDetailsFailure());
    }
    if (!_emailPattern.hasMatch(email)) {
      return const Left(RequestCallInvalidEmailFailure());
    }
    if (!param.hasAcceptedPrivacyPolicy) {
      return const Left(RequestCallConsentMissingFailure());
    }

    final requestId = await _callBookingRepository.requestCall(
      CallRequestEntity(
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
  RequestCallFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    CallSlotUnavailableException() => RequestCallSlotUnavailableFailure(
      cause: error,
    ),
    CallRequestLimitException() => RequestCallLimitFailure(cause: error),
    CallRequestInvalidException() => RequestCallInvalidFailure(cause: error),
    CallBookingNotSetUpException() => RequestCallNotSetUpFailure(cause: error),
    CallBookingNetworkException() => RequestCallNetworkFailure(cause: error),
    _ => RequestCallUnknownFailure(cause: error),
  };
}
