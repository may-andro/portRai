import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/data/cache/profile_cache.dart';
import 'package:portrai/src/feature/profile/data/model/profile_model.dart';

class MockProfileCache extends Mock implements ProfileCache {}

extension MockProfileCacheStub on MockProfileCache {
  void stubGet({required String locale, required ProfileModel? result}) {
    when(
      () => get(conditions: {'locale': locale}),
    ).thenAnswer((_) async => result);
  }

  void stubGetThrows({required String locale, required Object error}) {
    when(() => get(conditions: {'locale': locale})).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }

  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }
}
