import 'package:meta/meta.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/domain/repository/_repository.dart';
import 'package:use_case/use_case.dart';

sealed class WatchDeviceTokenRefreshesFailure extends BasicFailure {
  const WatchDeviceTokenRefreshesFailure({super.cause});
}

class WatchDeviceTokenRefreshesUnknownFailure
    extends WatchDeviceTokenRefreshesFailure {
  const WatchDeviceTokenRefreshesUnknownFailure({super.cause});
}

/// New tokens issued after this device's token changes.
@register
class WatchDeviceTokenRefreshesUseCase
    extends BaseNoParamStreamUseCase<String, WatchDeviceTokenRefreshesFailure> {
  WatchDeviceTokenRefreshesUseCase(this._notificationRepository);

  final NotificationRepository _notificationRepository;

  @protected
  @override
  Stream<String> execute() => _notificationRepository.deviceTokenRefreshes;

  @protected
  @override
  WatchDeviceTokenRefreshesFailure mapErrorToFailure(Object e, StackTrace st) {
    return WatchDeviceTokenRefreshesUnknownFailure(cause: e);
  }
}
