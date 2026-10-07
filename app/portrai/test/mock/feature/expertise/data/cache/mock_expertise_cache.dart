import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/data/cache/expertise_cache.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';

class MockExpertiseCache extends Mock implements ExpertiseCache {}

extension MockExpertiseCacheStub on MockExpertiseCache {
  void stubPut() {
    when(() => put(any())).thenAnswer((_) async {});
  }

  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }

  void stubQuery({
    required Map<String, Object?> conditions,
    required List<ExpertiseModel> result,
  }) {
    when(() => query(conditions: conditions)).thenAnswer((_) async => result);
  }

  void stubQueryThrows({
    required Map<String, Object?> conditions,
    required Object error,
  }) {
    when(() => query(conditions: conditions)).thenThrow(error);
  }
}
