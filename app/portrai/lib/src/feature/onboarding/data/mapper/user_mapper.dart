import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';

@register
class UserMapper implements BiMapper<UserModel, UserEntity> {
  const UserMapper();

  @override
  UserEntity to(UserModel from) {
    final role = UserRole.values.asNameMap()[from.role];
    if (role == null) throw FormatException('Unknown user role: ${from.role}');
    return UserEntity(role: role);
  }

  @override
  UserModel from(UserEntity to) => UserModel(role: to.role.name);
}
