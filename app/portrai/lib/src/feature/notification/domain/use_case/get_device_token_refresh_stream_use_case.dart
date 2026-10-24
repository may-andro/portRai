import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';

/// New tokens issued after this device's token changes.
@register
class GetDeviceTokenRefreshStreamUseCase {
  GetDeviceTokenRefreshStreamUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  Stream<String> call() => _notificationRepository.deviceTokenRefreshes;
}
