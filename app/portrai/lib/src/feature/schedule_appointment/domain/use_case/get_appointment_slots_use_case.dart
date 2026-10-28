import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/entity/_entity.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/exception/_exception.dart';
import 'package:portrai/src/feature/schedule_appointment/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetAppointmentSlotsFailure extends BasicFailure {
  const GetAppointmentSlotsFailure({super.cause});
}

@Localizable('errorScheduleAppointmentUnavailable')
class GetAppointmentSlotsNotSetUpFailure extends GetAppointmentSlotsFailure {
  const GetAppointmentSlotsNotSetUpFailure({super.cause});
}

@Localizable('errorScheduleAppointmentNetwork')
class GetAppointmentSlotsNetworkFailure extends GetAppointmentSlotsFailure {
  const GetAppointmentSlotsNetworkFailure({super.cause});
}

@Localizable('errorAppointmentSlotsUnknown')
class GetAppointmentSlotsUnknownFailure extends GetAppointmentSlotsFailure {
  const GetAppointmentSlotsUnknownFailure({super.cause});
}

/// The free times to schedule an appointment at, earliest first.
@register
class GetAppointmentSlotsUseCase
    extends
        BaseNoParamUseCase<AppointmentSlotsEntity, GetAppointmentSlotsFailure> {
  GetAppointmentSlotsUseCase(this._scheduleAppointmentRepository);

  final ScheduleAppointmentRepository _scheduleAppointmentRepository;

  @protected
  @override
  FutureOr<Either<GetAppointmentSlotsFailure, AppointmentSlotsEntity>>
  execute() async =>
      Right(await _scheduleAppointmentRepository.getAppointmentSlots());

  @protected
  @override
  GetAppointmentSlotsFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    ScheduleAppointmentNotSetUpException() =>
      GetAppointmentSlotsNotSetUpFailure(cause: error),
    ScheduleAppointmentNetworkException() => GetAppointmentSlotsNetworkFailure(
      cause: error,
    ),
    _ => GetAppointmentSlotsUnknownFailure(cause: error),
  };
}
