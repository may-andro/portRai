import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/exception/_exception.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

class DecideAppointmentRequestParam extends Equatable {
  const DecideAppointmentRequestParam({
    required this.requestId,
    required this.decision,
  });

  final String requestId;
  final AppointmentDecision decision;

  @override
  List<Object?> get props => [requestId, decision];
}

sealed class DecideAppointmentRequestFailure extends BasicFailure {
  const DecideAppointmentRequestFailure({super.cause});
}

@Localizable('errorAppointmentRequestsSignedOut')
class DecideAppointmentRequestSignedOutFailure
    extends DecideAppointmentRequestFailure {
  const DecideAppointmentRequestSignedOutFailure({super.cause});
}

@Localizable('errorAppointmentRequestNotFound')
class DecideAppointmentRequestNotFoundFailure
    extends DecideAppointmentRequestFailure {
  const DecideAppointmentRequestNotFoundFailure({super.cause});
}

@Localizable('errorAppointmentRequestNotAnswerable')
class DecideAppointmentRequestPermissionDeniedFailure
    extends DecideAppointmentRequestFailure {
  const DecideAppointmentRequestPermissionDeniedFailure({super.cause});
}

@Localizable('errorAppointmentRequestDecisionNetwork')
class DecideAppointmentRequestNetworkFailure
    extends DecideAppointmentRequestFailure {
  const DecideAppointmentRequestNetworkFailure({super.cause});
}

@Localizable('errorAppointmentRequestDecisionUnknown')
class DecideAppointmentRequestUnknownFailure
    extends DecideAppointmentRequestFailure {
  const DecideAppointmentRequestUnknownFailure({super.cause});
}

/// Accepts or declines a request sent to the signed-in owner. The visitor
/// then gets an email with the answer.
@register
class DecideAppointmentRequestUseCase
    extends
        BaseUseCase<
          void,
          DecideAppointmentRequestParam,
          DecideAppointmentRequestFailure
        > {
  DecideAppointmentRequestUseCase(
    this._getSignedInUserUseCase,
    this._appointmentRequestRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final AppointmentRequestRepository _appointmentRequestRepository;

  @protected
  @override
  FutureOr<Either<DecideAppointmentRequestFailure, void>> execute(
    DecideAppointmentRequestParam input,
  ) async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(
        DecideAppointmentRequestUnknownFailure(cause: signedInUserEither.left),
      );
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(DecideAppointmentRequestSignedOutFailure());
    }

    await _appointmentRequestRepository.decideAppointmentRequest(
      userId: signedInUser.id,
      id: input.requestId,
      decision: input.decision,
    );
    return const Right(null);
  }

  @protected
  @override
  DecideAppointmentRequestFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AppointmentRequestNotFoundException() =>
      DecideAppointmentRequestNotFoundFailure(cause: error),
    AppointmentRequestPermissionDeniedException() =>
      DecideAppointmentRequestPermissionDeniedFailure(cause: error),
    ScheduleAppointmentNetworkException() =>
      DecideAppointmentRequestNetworkFailure(cause: error),
    _ => DecideAppointmentRequestUnknownFailure(cause: error),
  };
}
