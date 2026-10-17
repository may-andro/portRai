import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/data/cache/_cache.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';

class MockUserCache extends Mock implements UserCache {}

extension MockUserCacheStub on MockUserCache {
  void stubGet(UserModel? userModel) {
    when(get).thenAnswer((_) async => userModel);
  }

  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }
}
