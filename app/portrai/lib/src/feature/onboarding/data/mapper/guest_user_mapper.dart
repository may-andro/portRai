import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';

@register
class GuestUserMapper implements BiMapper<GuestUserModel, GuestUserEntity> {
  const GuestUserMapper();

  @override
  GuestUserEntity to(GuestUserModel from) {
    final role = UserRole.values.asNameMap()[from.role];
    if (role == null) throw FormatException('Unknown user role: ${from.role}');
    return GuestUserEntity(role: role);
  }

  @override
  GuestUserModel from(GuestUserEntity to) => GuestUserModel(role: to.role.name);
}
