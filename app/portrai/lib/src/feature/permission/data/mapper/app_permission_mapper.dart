import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:portrai/src/feature/permission/domain/entity/_entity.dart';

@register
class AppPermissionMapper implements Mapper<AppPermission, Permission> {
  const AppPermissionMapper();

  @override
  Permission map(AppPermission from) => switch (from) {
    AppPermission.notifications => Permission.notification,
  };
}
