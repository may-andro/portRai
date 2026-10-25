import 'dart:async';

import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class GetInitialPushMessageFailure extends BasicFailure {
  const GetInitialPushMessageFailure({super.cause});
}

class GetInitialPushMessageUnknownFailure extends GetInitialPushMessageFailure {
  const GetInitialPushMessageUnknownFailure({super.cause});
}

/// The message whose notification opened the app, or null when the app was
/// opened another way.
@register
class GetInitialPushMessageUseCase
    extends
        BaseNoParamUseCase<PushMessageEntity?, GetInitialPushMessageFailure> {
  GetInitialPushMessageUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  @protected
  @override
  FutureOr<Either<GetInitialPushMessageFailure, PushMessageEntity?>>
  execute() async => Right(await _notificationRepository.getInitialMessage());

  @protected
  @override
  GetInitialPushMessageFailure mapErrorToFailure(
    Object error,
    StackTrace stackTrace,
  ) => GetInitialPushMessageUnknownFailure(cause: error);
}
