import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/profile/data/repository/remote_profile_repository_impl.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/domain/repository/mock_profile_repository.dart';
import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
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
    appLocale: appLocale,
  );
  final profile = createProfileEntity();
  final firestoreDocument = {'profile': createProfileJson()};

  group('RemoteProfileRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockProfileRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late RemoteProfileRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheDelegateRepository = MockProfileRepository();
      logReporter = MockLogReporter();
      repository = RemoteProfileRepositoryImpl(
        firestoreController,
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
    });

    test(
      'should return the cached profile when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetProfile(profile);

        final result = await repository.getProfile();

        expect(result, profile);
        verify(() => cacheDelegateRepository.getProfile()).called(1);
        verifyNever(
          () => firestoreController.getDocumentFromCollection(any(), any()),
        );
      },
    );

    test(
      'should load the profile from remote and cache it when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheProfile(profile);

        final result = await repository.getProfile();

        expect(result, profile);
        verify(
          () => firestoreController.getDocumentFromCollection(
            'profile',
            localeCode,
          ),
        ).called(1);
        verify(() => cacheDelegateRepository.cacheProfile(profile)).called(1);
      },
    );

    test(
      'should log the cache error and still load the profile from remote when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileCacheException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheProfile(profile);

        final result = await repository.getProfile();

        expect(result, profile);
        verify(
          () => logReporter.error(
            'Cache error while getting profile, loading from remote instead.',
            tag: 'RemoteProfileRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log and continue when caching the remote profile fails',
      () async {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheProfileThrows(
          profile: profile,
          error: Exception('cache write failed'),
        );

        final result = await repository.getProfile();

        expect(result, profile);
        verify(
          () => logReporter.error(
            'Failed to cache profile from remote, continuing without caching.',
            tag: 'RemoteProfileRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should throw an unauthorized exception when Firestore denies access',
      () {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollectionThrows(
          FirestorePermissionDeniedException(
            'read profile',
            StateError('forbidden'),
            StackTrace.empty,
          ),
        );

        expect(
          repository.getProfile,
          throwsA(isA<ProfileUnauthorizedException>()),
        );
      },
    );

    test(
      'should throw a parsing exception when the remote payload is invalid',
      () {
        cacheDelegateRepository.stubGetProfileThrows(
          const ProfileNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection({
          'profile': {'email': 'broken'},
        });

        expect(
          repository.getProfile(),
          throwsA(isA<ProfileParsingException>()),
        );
      },
    );
  });
}
