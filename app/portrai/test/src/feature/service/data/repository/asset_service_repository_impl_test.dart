import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/data/mapper/service_mapper.dart';
import 'package:portrai/src/feature/service/data/repository/asset_service_repository_impl.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

import '../../../../../mock/feature/service/domain/repository/mock_service_repository.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const service = ServiceEntity(
    image: 'service.png',
    title: 'App Development',
    description: 'Beautiful apps',
    detail: 'Detailed service description',
  );

  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> stubAssets(String contents) async {
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMessageHandler('flutter/assets', (message) async {
      final key = const StringCodec().decodeMessage(message);
      if (key == 'assets/dashboard/services.json') {
        return ByteData.view(Uint8List.fromList(utf8.encode(contents)).buffer);
      }
      return null;
    });
  }

  group('AssetServiceRepositoryImpl', () {
    late MockServiceRepository cacheRepository;
    late MockLogReporter logReporter;
    late AssetServiceRepositoryImpl repository;

    setUp(() async {
      cacheRepository = MockServiceRepository();
      logReporter = MockLogReporter();
      repository = AssetServiceRepositoryImpl(
        AppLocale('en'),
        cacheRepository,
        ServiceMapper(appLocale: AppLocale('en')),
        logReporter,
      );
      when(
        () => logReporter.error(any(), tag: any(named: 'tag')),
      ).thenReturn(null);
      when(
        () => logReporter.error(
          any(),
          tag: any(named: 'tag'),
          stacktrace: any(named: 'stacktrace'),
        ),
      ).thenReturn(null);
      await stubAssets(
        jsonEncode({
          'en': {
            'services': [
              {
                'title': service.title,
                'description': service.description,
                'image': service.image,
                'detail': service.detail,
              },
            ],
          },
        }),
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test(
      'should return cached services when the cache already has data',
      () async {
        cacheRepository.stubGetServices(const [service]);

        expect(await repository.getServices(), const [service]);
        verify(() => cacheRepository.getServices()).called(1);
        verifyNever(() => cacheRepository.cacheService(service));
      },
    );

    test(
      'should load services from assets and cache them when the cache is empty',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
        cacheRepository.stubCacheService(service);

        expect(await repository.getServices(), const [service]);
        verify(() => cacheRepository.getServices()).called(1);
        verify(() => cacheRepository.cacheService(service)).called(1);
      },
    );

    test(
      'should log the cache error and still load services from assets when reading the cache fails',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceCacheException());
        cacheRepository.stubCacheService(service);

        await repository.getServices();

        verify(
          () => logReporter.error(
            any(that: contains('Cache error while getting services')),
            tag: 'AssetServiceRepositoryImpl',
            stacktrace: any(named: 'stacktrace'),
          ),
        ).called(1);
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
        final invalidLocaleRepository = AssetServiceRepositoryImpl(
          AppLocale('fr'),
          cacheRepository,
          ServiceMapper(appLocale: AppLocale('fr')),
          logReporter,
        );

        expect(
          () => invalidLocaleRepository.getServices(),
          throwsA(isA<ServiceParsingException>()),
        );
      },
    );

    test(
      'should continue returning services when caching the loaded assets fails',
      () async {
        cacheRepository.stubGetServicesThrows(const ServiceNotFoundException());
        cacheRepository.stubCacheServiceThrows(
          service,
          const ServiceCacheException(),
        );

        expect(await repository.getServices(), const [service]);
        verify(
          () => logReporter.error(
            'Failed to cache services from assets, continuing without caching.',
            tag: 'AssetServiceRepositoryImpl',
          ),
        ).called(1);
      },
    );
  });
}
