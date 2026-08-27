import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/app_config/data/cache/_cache.dart';
import 'package:portrai/src/feature/app_config/domain/_domain.dart';

@register
class CacheAppConfigRepositoryImpl implements AppConfigRepository {
  CacheAppConfigRepositoryImpl(this._appConfigCache);

  final AppConfigCache _appConfigCache;

  @override
  Future<PortraiAppConfigEntity> getAppConfig() async {
    try {
      final cachedAppConfig = await _appConfigCache.get();

      if (cachedAppConfig == null) {
        throw const AppConfigNotFoundException(
          cause: 'App config not found in cache',
        );
      }

      return cachedAppConfig;
    } on AppConfigNotFoundException {
      rethrow;
    } catch (e, stackTrace) {
      throw AppConfigCacheException(
        cause: 'Unexpected error while retrieving app config from cache: $e',
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> cacheAppConfig(PortraiAppConfigEntity appConfig) async {
    try {
      await _appConfigCache.put(appConfig);
    } catch (e, stackTrace) {
      throw AppConfigCacheException(
        cause: 'Unexpected error while caching app config: $e',
        stackTrace: stackTrace,
      );
    }
  }
}
