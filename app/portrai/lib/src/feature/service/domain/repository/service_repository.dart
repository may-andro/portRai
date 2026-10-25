import 'package:portrai/src/feature/service/domain/entity/_entity.dart';

abstract class ServiceRepository {
  Future<List<ServiceEntity>> getServices();

  Future<void> cacheServices(List<ServiceEntity> services);

  /// Replaces the cached services of the current locale with the latest ones.
  Future<void> refreshServices();
}
