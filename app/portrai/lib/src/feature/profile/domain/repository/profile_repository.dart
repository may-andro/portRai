import 'package:portrai/src/feature/profile/domain/entity/_entity.dart';

abstract class ProfileRepository {
  Future<ProfileEntity> getProfile();

  Future<void> cacheProfile(ProfileEntity profile);
}
