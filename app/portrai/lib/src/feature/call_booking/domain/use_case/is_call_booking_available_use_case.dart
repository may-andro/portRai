import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/call_booking/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:use_case/use_case.dart';

/// Whether visitors can book a call. Off when the flag cannot be read.
@register
class IsCallBookingAvailableUseCase
    extends BaseNoParamUseCase<bool, NoFailure> {
  IsCallBookingAvailableUseCase(this._isFeatureEnabledUseCase);

  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;

  @protected
  @override
  FutureOr<Either<NoFailure, bool>> execute() async {
    final isFeatureEnabledEither = await _isFeatureEnabledUseCase(
      CallBookingFeatureFlags.callBooking,
    );
    return Right(
      isFeatureEnabledEither.isRight && isFeatureEnabledEither.right,
    );
  }

  @protected
  @override
  NoFailure mapErrorToFailure(Object error, StackTrace stackTrace) =>
      NoFailure();
}
