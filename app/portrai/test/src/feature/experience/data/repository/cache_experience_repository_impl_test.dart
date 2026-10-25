import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/data/repository/cache_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

import '../../../../../mock/feature/experience/data/cache/mock_experience_cache.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ExperienceMapper(appLocale: appLocale);

  group('CacheExperienceRepositoryImpl', () {
    late MockExperienceCache experienceCache;
    late CacheExperienceRepositoryImpl repository;

    setUp(() {
      experienceCache = MockExperienceCache();
      repository = CacheExperienceRepositoryImpl(
        experienceCache,
        mapper,
        appLocale,
      );
    });

    test(
      'should delete the cached experiences of the current locale when refreshed',
      () async {
        experienceCache.stubDelete(locale: localeCode);

        await repository.refreshExperiences();

        verify(() => experienceCache.delete({'locale': localeCode})).called(1);
      },
    );

    test(
      'should throw ExperienceCacheException when deleting the cached experiences fails',
      () {
        experienceCache.stubDeleteThrows(
          locale: localeCode,
          error: Exception('delete failed'),
        );

        expect(
          repository.refreshExperiences,
          throwsA(isA<ExperienceCacheException>()),
        );
      },
    );
  });
}
