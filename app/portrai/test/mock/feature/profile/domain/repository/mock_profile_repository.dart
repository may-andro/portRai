import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}

extension MockProfileRepositoryStub on MockProfileRepository {
  void stubGetProfile(ProfileEntity profile) {
    when(getProfile).thenAnswer((_) async => profile);
  }

  void stubGetProfileThrows(Object error) {
    when(getProfile).thenThrow(error);
  }

  void stubCacheProfile(ProfileEntity profile) {
    when(() => cacheProfile(profile)).thenAnswer((_) async {});
  }

  void stubCacheProfileThrows({
    required ProfileEntity profile,
    required Object error,
  }) {
    when(() => cacheProfile(profile)).thenThrow(error);
  }
}
