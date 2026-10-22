import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';

@register
class AppPermissionStatusMapper
    implements Mapper<PermissionStatus, AppPermissionStatus> {
  const AppPermissionStatusMapper();

  @override
  AppPermissionStatus map(PermissionStatus from) => switch (from) {
    PermissionStatus.granted ||
    PermissionStatus.limited ||
    PermissionStatus.provisional => AppPermissionStatus.granted,
    PermissionStatus.denied => AppPermissionStatus.denied,
    // A restricted permission (parental controls, device policy) cannot be
    // changed by the user from the app either.
    PermissionStatus.permanentlyDenied ||
    PermissionStatus.restricted => AppPermissionStatus.permanentlyDenied,
  };
}
