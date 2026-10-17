import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';

abstract class UserRepository {
  Future<UserEntity?> getUser();

  Future<void> saveUser(UserEntity user);
}
