import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/data/cache/_cache.dart';
import 'package:portrai/src/feature/service/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@register
class CacheServiceRepositoryImpl implements ServiceRepository {
  CacheServiceRepositoryImpl(this._serviceCache, this._mapper, this._appLocale);

  final ServiceCache _serviceCache;
  final ServiceMapper _mapper;
  final AppLocale _appLocale;

  @override
  Future<void> cacheServices(List<ServiceEntity> services) async {
    try {
      return await _serviceCache.putAll(services.map(_mapper.from));
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ServiceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServiceCacheException(
        cause: 'Unexpected error while caching services: $e',
        stackTrace: stackTrace,
      );
    }
  }

  /// Drops the cached services of the current locale, so the next read loads
  /// them again.
  @override
  Future<void> refreshServices() async {
    try {
      await _serviceCache.delete({'locale': _appLocale.languageCode});
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ServiceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServiceCacheException(
        cause: 'Unexpected error while clearing services: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<ServiceEntity>> getServices() async {
    try {
      final currentLocale = _appLocale.languageCode;

      final servicesList = await _serviceCache.query(
        conditions: {'locale': currentLocale},
      );

      if (servicesList.isEmpty) {
        throw const ServiceNotFoundException(
          cause: 'No services found in cache for current locale',
        );
      }

      return servicesList.map(_mapper.to).toList();
    } on ServiceNotFoundException {
      rethrow;
    } on DBNotInitialisedException catch (e, stackTrace) {
      throw ServiceCacheException(
        cause: 'Database not initialized: $e',
        stackTrace: stackTrace,
      );
    } catch (e, stackTrace) {
      throw ServiceNotFoundException(
        cause: 'Unexpected error while retrieving services: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
