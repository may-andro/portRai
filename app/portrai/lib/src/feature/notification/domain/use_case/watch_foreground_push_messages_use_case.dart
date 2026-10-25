import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchForegroundPushMessagesFailure extends BasicFailure {
  const WatchForegroundPushMessagesFailure({super.cause});
}

class WatchForegroundPushMessagesUnknownFailure
    extends WatchForegroundPushMessagesFailure {
  const WatchForegroundPushMessagesUnknownFailure({super.cause});
}

/// Messages received while the app is in the foreground, which the system
/// does not display.
@register
class WatchForegroundPushMessagesUseCase
    extends
        BaseNoParamStreamUseCase<
          PushMessageEntity,
          WatchForegroundPushMessagesFailure
        > {
  WatchForegroundPushMessagesUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  @protected
  @override
  Stream<PushMessageEntity> execute() =>
      _notificationRepository.foregroundMessages;

  @protected
  @override
  WatchForegroundPushMessagesFailure mapErrorToFailure(
    Object e,
    StackTrace st,
  ) {
    return WatchForegroundPushMessagesUnknownFailure(cause: e);
  }
}
