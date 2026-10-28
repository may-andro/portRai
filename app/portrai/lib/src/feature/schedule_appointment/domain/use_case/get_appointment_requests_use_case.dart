import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/exception/_exception.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetAppointmentRequestsFailure extends BasicFailure {
  const GetAppointmentRequestsFailure({super.cause});
}

@Localizable('errorAppointmentRequestsSignedOut')
class GetAppointmentRequestsSignedOutFailure
    extends GetAppointmentRequestsFailure {
  const GetAppointmentRequestsSignedOutFailure({super.cause});
}

@Localizable('errorAppointmentRequestsPermissionDenied')
class GetAppointmentRequestsPermissionDeniedFailure
    extends GetAppointmentRequestsFailure {
  const GetAppointmentRequestsPermissionDeniedFailure({super.cause});
}

@Localizable('errorAppointmentRequestsNetwork')
class GetAppointmentRequestsNetworkFailure
    extends GetAppointmentRequestsFailure {
  const GetAppointmentRequestsNetworkFailure({super.cause});
}

@Localizable('errorAppointmentRequestsUnknown')
class GetAppointmentRequestsUnknownFailure
    extends GetAppointmentRequestsFailure {
  const GetAppointmentRequestsUnknownFailure({super.cause});
}

/// The requests sent to the signed-in owner, earliest slot first.
@register
class GetAppointmentRequestsUseCase
    extends
        BaseNoParamUseCase<
          List<ReceivedAppointmentRequestEntity>,
          GetAppointmentRequestsFailure
        > {
  GetAppointmentRequestsUseCase(
    this._getSignedInUserUseCase,
    this._appointmentRequestRepository,
  );

  final GetSignedInUserUseCase _getSignedInUserUseCase;
  final AppointmentRequestRepository _appointmentRequestRepository;

  @protected
  @override
  FutureOr<
    Either<
      GetAppointmentRequestsFailure,
      List<ReceivedAppointmentRequestEntity>
    >
  >
  execute() async {
    final signedInUserEither = await _getSignedInUserUseCase();
    if (signedInUserEither.isLeft) {
      return Left(
        GetAppointmentRequestsUnknownFailure(cause: signedInUserEither.left),
      );
    }
    final signedInUser = signedInUserEither.right;
    if (signedInUser == null) {
      return const Left(GetAppointmentRequestsSignedOutFailure());
    }

    final requests = await _appointmentRequestRepository.getAppointmentRequests(
      signedInUser.id,
    );
    return Right(
      [...requests]
        ..sort((first, second) => first.slotStart.compareTo(second.slotStart)),
    );
  }

  @protected
  @override
  GetAppointmentRequestsFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    AppointmentRequestPermissionDeniedException() =>
      GetAppointmentRequestsPermissionDeniedFailure(cause: error),
    ScheduleAppointmentNetworkException() =>
      GetAppointmentRequestsNetworkFailure(cause: error),
    _ => GetAppointmentRequestsUnknownFailure(cause: error),
  };
}
