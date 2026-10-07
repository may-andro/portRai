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

  void stubCacheService(ServiceEntity service) {
    when(() => cacheService(service)).thenAnswer((_) async {});
  }

  void stubCacheServiceThrows(ServiceEntity service, Object error) {
    when(() => cacheService(service)).thenThrow(error);
  }
}
