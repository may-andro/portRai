import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';

/// Messages whose notification was tapped while the app was running.
@register
class GetOpenedPushMessageStreamUseCase {
  GetOpenedPushMessageStreamUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Stream<PushMessageEntity> call() => _notificationRepository.openedMessages;
}
