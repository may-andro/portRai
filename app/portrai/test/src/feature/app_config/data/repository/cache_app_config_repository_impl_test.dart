import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/repository/cache_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/exception/app_config_exception.dart';

import '../../../../../mock/feature/app_config/data/cache/mock_app_config_cache.dart';
import '../../../../../mock/feature/app_config/domain/entity/fake_portrai_app_config_entity.dart';

void main() {
  group('CacheAppConfigRepositoryImpl', () {
    late MockAppConfigCache appConfigCache;
    late CacheAppConfigRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakePortraiAppConfigEntity());
    });

    setUp(() {
      appConfigCache = MockAppConfigCache();
      repository = CacheAppConfigRepositoryImpl(appConfigCache);
    });

    group('getAppConfig', () {
      test('should return the cached app config when present', () async {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
        );
        appConfigCache.stubGet(appConfig);

        final result = await repository.getAppConfig();

        expect(result, appConfig);
      });

      test(
        'should throw AppConfigNotFoundException when nothing is cached',
        () {
          appConfigCache.stubGet(null);

          expect(
            repository.getAppConfig,
            throwsA(isA<AppConfigNotFoundException>()),
          );
        },
      );

      test('should throw AppConfigCacheException when the cache throws', () {
        appConfigCache.stubGetThrows(Exception('cache read failed'));

        expect(
          repository.getAppConfig,
          throwsA(isA<AppConfigCacheException>()),
        );
      });
    });

    group('cacheAppConfig', () {
      test('should store the app config in the cache', () async {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
        );
        appConfigCache.stubPut();

        await repository.cacheAppConfig(appConfig);

        verify(() => appConfigCache.put(appConfig)).called(1);
      });

      test('should throw AppConfigCacheException when the cache throws', () {
        const appConfig = PortraiAppConfigEntity(
          minimumRequiredAppVersion: '1.0.0',
        );
        appConfigCache.stubPutThrows(Exception('cache write failed'));

        expect(
          () => repository.cacheAppConfig(appConfig),
          throwsA(isA<AppConfigCacheException>()),
        );
      });
    });
  });
}
