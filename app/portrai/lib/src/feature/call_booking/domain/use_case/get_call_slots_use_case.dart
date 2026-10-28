import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/domain/entity/_entity.dart';
import 'package:portrai/src/feature/call_booking/domain/exception/_exception.dart';
import 'package:portrai/src/feature/call_booking/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetCallSlotsFailure extends BasicFailure {
  const GetCallSlotsFailure({super.cause});
}

@Localizable('errorCallBookingUnavailable')
class GetCallSlotsNotSetUpFailure extends GetCallSlotsFailure {
  const GetCallSlotsNotSetUpFailure({super.cause});
}

@Localizable('errorCallBookingNetwork')
class GetCallSlotsNetworkFailure extends GetCallSlotsFailure {
  const GetCallSlotsNetworkFailure({super.cause});
}

@Localizable('errorCallSlotsUnknown')
class GetCallSlotsUnknownFailure extends GetCallSlotsFailure {
  const GetCallSlotsUnknownFailure({super.cause});
}

/// The free times to book a call at, earliest first.
@register
class GetCallSlotsUseCase
    extends BaseNoParamUseCase<CallSlotsEntity, GetCallSlotsFailure> {
  GetCallSlotsUseCase(this._callBookingRepository);

  final CallBookingRepository _callBookingRepository;

  @protected
  @override
  FutureOr<Either<GetCallSlotsFailure, CallSlotsEntity>> execute() async =>
      Right(await _callBookingRepository.getCallSlots());

  @protected
  @override
  GetCallSlotsFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => switch (error) {
    CallBookingNotSetUpException() => GetCallSlotsNotSetUpFailure(cause: error),
    CallBookingNetworkException() => GetCallSlotsNetworkFailure(cause: error),
    _ => GetCallSlotsUnknownFailure(cause: error),
  };
}
