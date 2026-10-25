import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class ResetDeviceTokenFailure extends BasicFailure {
  const ResetDeviceTokenFailure({super.cause});
}

class ResetDeviceTokenUnknownFailure extends ResetDeviceTokenFailure {
  const ResetDeviceTokenUnknownFailure({super.cause});
}

/// Replaces this device's token, so notifications sent to the old one, such
/// as those for a user who signed out, no longer arrive.
@register
class ResetDeviceTokenUseCase
    extends BaseNoParamUseCase<void, ResetDeviceTokenFailure> {
  ResetDeviceTokenUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  @protected
  @override
  FutureOr<Either<ResetDeviceTokenFailure, void>> execute() async {
    await _notificationRepository.deleteDeviceToken();
    return const Right(null);
  }

  @protected
  @override
  ResetDeviceTokenFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => ResetDeviceTokenUnknownFailure(cause: error);
}
