import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/data/cache/service_cache.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';

class MockServiceCache extends Mock implements ServiceCache {}

extension MockServiceCacheStub on MockServiceCache {
  void stubPut() {
    when(() => put(any())).thenAnswer((_) async {});
  }

  void stubPutThrows(Object error) {
    when(() => put(any())).thenThrow(error);
  }

  void stubQuery(List<ServiceModel> services) {
    when(
      () => query(conditions: any(named: 'conditions')),
    ).thenAnswer((_) async => services);
  }

  void stubQueryThrows(Object error) {
    when(() => query(conditions: any(named: 'conditions'))).thenThrow(error);
  }
}
