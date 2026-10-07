import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/data/cache/project_cache.dart';
import 'package:portrai/src/feature/project/data/model/project_model.dart';

class MockProjectCache extends Mock implements ProjectCache {}

extension MockProjectCacheStub on MockProjectCache {
  void stubGet({
    required Map<String, Object?> conditions,
    required ProjectModel? result,
  }) {
    when(() => get(conditions: conditions)).thenAnswer((_) async => result);
  }

  void stubGetThrows({
    required Map<String, Object?> conditions,
    required Object error,
  }) {
    when(() => get(conditions: conditions)).thenThrow(error);
  }

  void stubPut() {
    when(() => put(any())).thenAnswer((_) async => true);
  }

  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }

  void stubQuery({
    required Map<String, Object?> conditions,
    required List<ProjectModel> result,
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
