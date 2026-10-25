import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/repository/asset_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/asset_source/domain/use_case/mock_get_asset_source_use_case.dart';
import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ExpertiseMapper(appLocale: appLocale);
  final expertiseList = [
    const ExpertiseEntity(
      image: 'https://example.com/flutter.png',
      title: 'Flutter Development',
      skills: [
        SkillEntity(name: 'Flutter SDK'),
        SkillEntity(name: 'State Management'),
      ],
    ),
    const ExpertiseEntity(
      image: 'https://example.com/android.png',
      title: 'Android Development',
      skills: [
        SkillEntity(name: 'Kotlin'),
        SkillEntity(name: 'Coroutines'),
      ],
    ),
  ];
  final assetsJson = jsonEncode({
    localeCode: {
      'experties': [
        {
          'image': expertiseList[0].image,
          'title': expertiseList[0].title,
          'skills': [
            for (final s in expertiseList[0].skills) {'name': s.name},
          ],
        },
        {
          'image': expertiseList[1].image,
          'title': expertiseList[1].title,
          'skills': [
            for (final s in expertiseList[1].skills) {'name': s.name},
          ],
        },
      ],
    },
  });

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetExpertiseRepositoryImpl', () {
    late MockExpertiseRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late FakeErrorReporter errorReporter;
    late MockGetAssetSourceUseCase getAssetSourceUseCase;
    late AssetExpertiseRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockExpertiseRepository();
      logReporter = MockLogReporter();
      errorReporter = FakeErrorReporter();
      getAssetSourceUseCase = MockGetAssetSourceUseCase()
        ..stubCall(AssetSource.real);
      repository = AssetExpertiseRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
        errorReporter,
        getAssetSourceUseCase,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = const StringCodec().decodeMessage(message);
            if (key == 'assets/dashboard/expertise.json' ||
                key == 'assets/dashboard/expertise.template.json') {
              return assetResponse();
            }
            return null;
          });
    });

    tearDown(() {
      rootBundle.evict('assets/dashboard/expertise.json');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test(
      'should return cached expertise when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(() => cacheDelegateRepository.getAllExpertise()).called(1);
        verifyNever(
          () => cacheDelegateRepository.cacheAllExpertise(expertiseList),
        );
      },
    );

    test(
      'should load expertise from assets and cache it when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        cacheDelegateRepository.stubCacheAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(
          () => cacheDelegateRepository.cacheAllExpertise(expertiseList),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load expertise from assets when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseCacheException(cause: 'db down'),
        );
        cacheDelegateRepository.stubCacheAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(
          () => logReporter.error(
            'Cache error while getting expertise: db down',
            tag: 'AssetExpertiseRepositoryImpl',
            stacktrace: any(named: 'stacktrace'),
          ),
        ).called(1);
      },
    );

    test(
      'should report the error and continue when caching expertise loaded from assets fails',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        cacheDelegateRepository.stubCacheAllExpertiseThrows(
          expertiseList: expertiseList,
          error: const ExpertiseCacheException(cause: 'cache write failed'),
        );

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        final reportedError = errorReporter.reportedErrors.single;
        expect(reportedError.exception, isA<ExpertiseCacheException>());
        expect(reportedError.tag, 'AssetExpertiseRepositoryImpl');
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              final key = const StringCodec().decodeMessage(message);
              if (key == 'assets/dashboard/expertise.json' ||
                  key == 'assets/dashboard/expertise.template.json') {
                return ByteData.sublistView(
                  Uint8List.fromList(utf8.encode('{invalid json')),
                );
              }
              return null;
            });
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );

        rootBundle.evict('assets/dashboard/expertise.json');

        expect(
          repository.getAllExpertise,
          throwsA(isA<ExpertiseParsingException>()),
        );
      },
    );

    test(
      'should load expertise from assets without using the cache when the asset source is template',
      () async {
        getAssetSourceUseCase.stubCall(AssetSource.template);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verifyZeroInteractions(cacheDelegateRepository);
      },
    );

    test('should leave the cache untouched when refreshed', () async {
      await repository.refreshAllExpertise();

      verifyZeroInteractions(cacheDelegateRepository);
    });
  });
}
