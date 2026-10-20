import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/user/data/cache/_cache.dart';
import 'package:portrai/src/feature/user/data/model/_model.dart';

class MockGuestUserCache extends Mock implements GuestUserCache {}

extension MockGuestUserCacheStub on MockGuestUserCache {
  void stubGet(GuestUserModel? userModel) {
    when(get).thenAnswer((_) async => userModel);
  }

  void stubGetThrows(Object error) {
    when(get).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }
}
