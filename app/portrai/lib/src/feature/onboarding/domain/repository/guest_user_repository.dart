import 'package:portrai/src/feature/onboarding/domain/entity/_entity.dart';

abstract class GuestUserRepository {
  Future<GuestUserEntity?> getGuestUser();

  Future<void> saveGuestUser(GuestUserEntity user);
}
