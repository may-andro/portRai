import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchOpenedPushMessagesFailure extends BasicFailure {
  const WatchOpenedPushMessagesFailure({super.cause});
}

class WatchOpenedPushMessagesUnknownFailure
    extends WatchOpenedPushMessagesFailure {
  const WatchOpenedPushMessagesUnknownFailure({super.cause});
}

/// Messages whose notification was tapped while the app was running.
@register
class WatchOpenedPushMessagesUseCase
    extends
        BaseNoParamStreamUseCase<
          PushMessageEntity,
          WatchOpenedPushMessagesFailure
        > {
  WatchOpenedPushMessagesUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  @protected
  @override
  Stream<PushMessageEntity> execute() => _notificationRepository.openedMessages;

  @protected
  @override
  WatchOpenedPushMessagesFailure mapErrorToFailure(Object e, StackTrace st) {
    return WatchOpenedPushMessagesUnknownFailure(cause: e);
  }
}
