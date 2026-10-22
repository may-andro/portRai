import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

class MockServiceRepository extends Mock implements ServiceRepository {}

extension MockServiceRepositoryStub on MockServiceRepository {
  void stubGetServices(List<ServiceEntity> services) {
    when(() => getServices()).thenAnswer((_) async => services);
  }

  void stubGetServicesThrows(Object error) {
    when(() => getServices()).thenThrow(error);
  }

  void stubCacheServices(List<ServiceEntity> services) {
    when(() => cacheServices(services)).thenAnswer((_) async {});
  }

  void stubCacheServicesThrows(List<ServiceEntity> services, Object error) {
    when(() => cacheServices(services)).thenThrow(error);
  }
}
