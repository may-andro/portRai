import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';

/// Messages received while the app is in the foreground, which the system
/// does not display.
@register
class GetForegroundPushMessageStreamUseCase {
  GetForegroundPushMessageStreamUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Stream<PushMessageEntity> call() =>
      _notificationRepository.foregroundMessages;
}
