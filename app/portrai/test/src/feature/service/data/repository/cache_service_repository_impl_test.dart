import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/data/mapper/service_mapper.dart';
import 'package:portrai/src/feature/service/data/model/service_model.dart';
import 'package:portrai/src/feature/service/data/repository/cache_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/data/cache/mock_service_cache.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );
  final model = ServiceModel(
    title: 'App Development',
    description: 'Beautiful apps',
    image: 'service.png',
    detail: 'Detailed service description',
    locale: 'en',
  );

  group('CacheServiceRepositoryImpl', () {
    late MockServiceCache cache;
    late CacheServiceRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(model);
    });

    setUp(() {
      cache = MockServiceCache();
      repository = CacheServiceRepositoryImpl(
        cache,
        ServiceMapper(appLocale: AppLocale('en')),
        AppLocale('en'),
      );
    });

    test('should cache a service when the cache write succeeds', () async {
      cache.stubPut();

      await repository.cacheService(service);

      verify(() => cache.put(any())).called(1);
    });

    test(
      'should throw a cache exception when the cache database is not initialised while writing',
      () {
        cache.stubPutThrows(
          const DBNotInitialisedException(cause: 'database not ready'),
        );

        expect(
          () => repository.cacheService(service),
          throwsA(isA<ServiceCacheException>()),
        );
      },
    );

    test(
      'should query the cache for the current locale when reading services',
      () async {
        cache.stubQuery([model]);

        expect(await repository.getServices(), const [service]);
        verify(() => cache.query(conditions: {'locale': 'en'})).called(1);
      },
    );

    test('should throw not found when the cache has no services', () {
      cache.stubQuery(const []);

      expect(
        () => repository.getServices(),
        throwsA(isA<ServiceNotFoundException>()),
      );
    });

    test(
      'should throw a cache exception when the cache database is not initialised while reading',
      () {
        cache.stubQueryThrows(
          const DBNotInitialisedException(cause: 'database not ready'),
        );

        expect(
          () => repository.getServices(),
          throwsA(isA<ServiceCacheException>()),
        );
      },
    );
  });
}
