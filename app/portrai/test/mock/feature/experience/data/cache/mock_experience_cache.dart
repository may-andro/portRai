import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/data/cache/experience_cache.dart';

class MockExperienceCache extends Mock implements ExperienceCache {}

extension MockExperienceCacheStub on MockExperienceCache {
  void stubDelete({required String locale}) {
    when(() => delete({'locale': locale})).thenAnswer((_) async {});
  }

  void stubDeleteThrows({required String locale, required Object error}) {
    when(() => delete({'locale': locale})).thenThrow(error);
  }
}
