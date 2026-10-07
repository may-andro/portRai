import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/profile_model.dart';
import 'package:portrai/src/feature/profile/data/repository/cache_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/data/cache/mock_profile_cache.dart';
import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  const localeCode = 'en';
  final mapper = ProfileMapper(
    publishedAtMapper: const PublishedAtMapper(),
    resumeMapper: const ResumeMapper(),
    socialLinkMapper: const SocialLinkMapper(),
    availabilityMapper: const AvailabilityMapper(),
    workingHoursMapper: const WorkingHoursMapper(),
    locationMapper: const LocationMapper(
      coordinatesMapper: CoordinatesMapper(),
    ),
    languageMapper: const LanguageMapper(),
    educationMapper: const EducationMapper(),
    appLocale: AppLocale(localeCode),
  );
  final profile = createProfileEntity();
  final model = createProfileModel();

  group('CacheProfileRepositoryImpl', () {
    late MockProfileCache profileCache;
    late CacheProfileRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(model);
    });

    setUp(() {
      profileCache = MockProfileCache();
      repository = CacheProfileRepositoryImpl(
        profileCache,
        mapper,
        AppLocale(localeCode),
      );
    });

    test('should return the cached profile when present', () async {
      profileCache.stubGet(locale: localeCode, result: model);

      final result = await repository.getProfile();

      expect(result, profile);
    });

    test('should throw ProfileNotFoundException when nothing is cached', () {
      profileCache.stubGet(locale: localeCode, result: null);

      expect(repository.getProfile, throwsA(isA<ProfileNotFoundException>()));
    });

    test(
      'should throw ProfileCacheException when the cache read is unavailable',
      () {
        profileCache.stubGetThrows(
          locale: localeCode,
          error: DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(repository.getProfile, throwsA(isA<ProfileCacheException>()));
      },
    );

    test(
      'should throw ProfileCacheException when the cache read fails unexpectedly',
      () {
        profileCache.stubGetThrows(
          locale: localeCode,
          error: Exception('boom'),
        );

        expect(repository.getProfile, throwsA(isA<ProfileCacheException>()));
      },
    );

    test(
      'should store the profile in the cache when caching succeeds',
      () async {
        profileCache.stubPut();

        await repository.cacheProfile(profile);

        final captured =
            verify(() => profileCache.put(captureAny())).captured.single
                as ProfileModel;
        expect(captured.toJson(), model.toJson());
      },
    );

    test(
      'should throw ProfileCacheException when the cache write is unavailable',
      () {
        profileCache.stubPutThrows(
          DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(
          () => repository.cacheProfile(profile),
          throwsA(isA<ProfileCacheException>()),
        );
      },
    );
  });
}
