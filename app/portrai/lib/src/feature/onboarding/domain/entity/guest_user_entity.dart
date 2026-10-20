import 'package:portrai/src/feature/onboarding/domain/entity/user_role.dart';
import 'package:portrai/src/feature/user/user.dart';

/// A visitor who has not signed in, known only by the role they picked during
/// onboarding. The role is saved on the device.
class GuestUserEntity extends UserEntity {
  const GuestUserEntity({required this.role});

  final UserRole role;

  @override
  List<Object?> get props => [role];
}
