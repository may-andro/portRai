import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/model/expertise_model.dart';
import 'package:portrai/src/feature/expertise/data/model/skill_model.dart';
import 'package:portrai/src/feature/expertise/data/repository/cache_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/data/cache/mock_expertise_cache.dart';

void main() {
  const localeCode = 'es';
  final appLocale = AppLocale(localeCode);
  final mapper = ExpertiseMapper(appLocale: appLocale);
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Flutter Development',
    skills: [
      SkillEntity(name: 'Flutter SDK'),
      SkillEntity(name: 'State Management'),
    ],
  );

  group('CacheExpertiseRepositoryImpl', () {
    late MockExpertiseCache expertiseCache;
    late CacheExpertiseRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(<ExpertiseModel>[]);
    });

    setUp(() {
      expertiseCache = MockExpertiseCache();
      repository = CacheExpertiseRepositoryImpl(
        expertiseCache,
        mapper,
        appLocale,
      );
    });

    test(
      'should cache expertise with the mapped locale when caching succeeds',
      () async {
        expertiseCache.stubPutAll();

        await repository.cacheAllExpertise([expertise]);

        final capturedModel =
            (verify(() => expertiseCache.putAll(captureAny())).captured.single
                    as Iterable<ExpertiseModel>)
                .single;
        expect(capturedModel.image, expertise.image);
        expect(capturedModel.title, expertise.title);
        expect(capturedModel.skills.map((s) => s.name), expertise.skillNames);
        expect(capturedModel.locale, localeCode);
      },
    );

    test(
      'should throw a cache exception when the database is not initialised while caching expertise',
      () {
        final error = DBNotInitialisedException(cause: Exception('db'));
        expertiseCache.stubPutAllThrows(error);

        expect(
          () => repository.cacheAllExpertise([expertise]),
          throwsA(
            isA<ExpertiseCacheException>().having(
              (exception) => exception.cause,
              'cause',
              contains('Database not initialized'),
            ),
          ),
        );
      },
    );

    test('should return mapped expertise when cached records exist', () async {
      expertiseCache.stubQuery(
        conditions: {'locale': localeCode},
        result: [
          ExpertiseModel(
            image: expertise.image,
            title: expertise.title,
            skills: [
              for (final s in expertise.skills) SkillModel(name: s.name),
            ],
            locale: localeCode,
          ),
        ],
      );

      final result = await repository.getAllExpertise();

      expect(result, [expertise]);
    });

    test(
      'should throw a not found exception when the cache has no records for the current locale',
      () {
        expertiseCache.stubQuery(
          conditions: {'locale': localeCode},
          result: [],
        );

        expect(
          repository.getAllExpertise,
          throwsA(isA<ExpertiseNotFoundException>()),
        );
      },
    );

    test(
      'should throw a cache exception when the database is not initialised while reading expertise',
      () {
        expertiseCache.stubQueryThrows(
          conditions: {'locale': localeCode},
          error: DBNotInitialisedException(cause: Exception('db')),
        );

        expect(
          repository.getAllExpertise,
          throwsA(isA<ExpertiseCacheException>()),
        );
      },
    );
  });
}
