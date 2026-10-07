import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/repository/asset_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';
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
      skills: ['Flutter SDK', 'State Management'],
    ),
    const ExpertiseEntity(
      image: 'https://example.com/android.png',
      title: 'Android Development',
      skills: ['Kotlin', 'Coroutines'],
    ),
  ];
  final assetsJson = jsonEncode({
    localeCode: {
      'experties': [
        {
          'image': expertiseList[0].image,
          'title': expertiseList[0].title,
          'skills': expertiseList[0].skills,
        },
        {
          'image': expertiseList[1].image,
          'title': expertiseList[1].title,
          'skills': expertiseList[1].skills,
        },
      ],
    },
  });

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetExpertiseRepositoryImpl', () {
    late MockExpertiseRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late AssetExpertiseRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockExpertiseRepository();
      logReporter = MockLogReporter();
      repository = AssetExpertiseRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = const StringCodec().decodeMessage(message);
            if (key == 'assets/dashboard/expertise.json') {
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
        for (final expertise in expertiseList) {
          verifyNever(() => cacheDelegateRepository.cacheExpertise(expertise));
        }
      },
    );

    test(
      'should load expertise from assets and cache it when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        for (final expertise in expertiseList) {
          cacheDelegateRepository.stubCacheExpertise(expertise);
        }

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        for (final expertise in expertiseList) {
          verify(
            () => cacheDelegateRepository.cacheExpertise(expertise),
          ).called(1);
        }
      },
    );

    test(
      'should log the cache error and still load expertise from assets when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseCacheException(cause: 'db down'),
        );
        for (final expertise in expertiseList) {
          cacheDelegateRepository.stubCacheExpertise(expertise);
        }

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
      'should log and continue when caching expertise loaded from assets fails',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        cacheDelegateRepository.stubCacheExpertiseThrows(
          expertise: expertiseList.first,
          error: Exception('cache write failed'),
        );

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(
          () => logReporter.error(
            'Failed to cache expertise from assets, continuing without caching.',
            tag: 'AssetExpertiseRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              final key = const StringCodec().decodeMessage(message);
              if (key == 'assets/dashboard/expertise.json') {
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
  });
}
