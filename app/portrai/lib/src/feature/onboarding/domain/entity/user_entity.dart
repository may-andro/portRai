import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/onboarding/domain/entity/user_role.dart';

/// The person using the app. New user attributes belong here, not in extra
/// single-purpose entities.
class UserEntity extends Equatable {
  const UserEntity({required this.role});

  final UserRole role;

  @override
  List<Object?> get props => [role];
}
