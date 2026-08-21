import 'package:portrai/src/feature/service/domain/entity/_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices();

  Future<void> cacheService(ServiceEntity expert);
}
