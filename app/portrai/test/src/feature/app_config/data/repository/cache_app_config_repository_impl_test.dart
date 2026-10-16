import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/app_config/app_config.dart';
import 'package:portrai/src/feature/app_config/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/app_config/data/model/_model.dart';
import 'package:portrai/src/feature/app_config/data/repository/cache_app_config_repository_impl.dart';
import 'package:portrai/src/feature/app_config/domain/exception/app_config_exception.dart';

import '../../../../../mock/feature/app_config/data/cache/fake_portrai_app_config_model.dart';
import '../../../../../mock/feature/app_config/data/cache/mock_app_config_cache.dart';

void main() {
  group('CacheAppConfigRepositoryImpl', () {
    late MockAppConfigCache appConfigCache;
    late CacheAppConfigRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(FakePortraiAppConfigModel());
    });

    setUp(() {
      appConfigCache = MockAppConfigCache();
      repository = CacheAppConfigRepositoryImpl(
        appConfigCache,
        const PortraiAppConfigMapper(AiImageAppConfigMapper()),
      );
    });

    group('getAppConfig', () {
      test('should return the cached app config when present', () async {
        appConfigCache.stubGet(
          const PortraiAppConfigModel(
            minimumRequiredAppVersion: '1.0.0',
            aiImage: AiImageAppConfigModel(model: 'model', style: 'naruto'),
          ),
        );

        final result = await repository.getAppConfig();

        expect(
          result,
          const PortraiAppConfigEntity(
            minimumRequiredAppVersion: '1.0.0',
            aiImage: AiImageAppConfig(model: 'model', style: 'naruto'),
          ),
        );
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

        final stored =
            verify(() => appConfigCache.put(captureAny())).captured.single
                as PortraiAppConfigModel;
        expect(stored.minimumRequiredAppVersion, '1.0.0');
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
