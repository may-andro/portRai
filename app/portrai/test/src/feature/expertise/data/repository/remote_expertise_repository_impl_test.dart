import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/data/mapper/expertise_mapper.dart';
import 'package:portrai/src/feature/expertise/data/repository/remote_expertise_repository_impl.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
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
  final firestoreDocument = {
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
  };

  group('RemoteExpertiseRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockExpertiseRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late FakeErrorReporter errorReporter;
    late RemoteExpertiseRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheDelegateRepository = MockExpertiseRepository();
      logReporter = MockLogReporter();
      errorReporter = FakeErrorReporter();
      repository = RemoteExpertiseRepositoryImpl(
        firestoreController,
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
        errorReporter,
      );
    });

    test(
      'should return cached expertise when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(() => cacheDelegateRepository.getAllExpertise()).called(1);
        verifyNever(
          () => firestoreController.getDocumentFromCollection(any(), any()),
        );
      },
    );

    test(
      'should load expertise from remote and cache it when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(
          () => firestoreController.getDocumentFromCollection(
            'expertise',
            localeCode,
          ),
        ).called(1);
        verify(
          () => cacheDelegateRepository.cacheAllExpertise(expertiseList),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load expertise from remote when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseCacheException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheAllExpertise(expertiseList);

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        verify(
          () => logReporter.error(
            'Cache error while getting expertise, loading from remote instead.',
            tag: 'RemoteExpertiseRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should report the error and continue when caching expertise loaded from remote fails',
      () async {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheAllExpertiseThrows(
          expertiseList: expertiseList,
          error: const ExpertiseCacheException(cause: 'cache write failed'),
        );

        final result = await repository.getAllExpertise();

        expect(result, expertiseList);
        final reportedError = errorReporter.reportedErrors.single;
        expect(reportedError.exception, isA<ExpertiseCacheException>());
        expect(reportedError.tag, 'RemoteExpertiseRepositoryImpl');
      },
    );

    test(
      'should throw an unauthorized exception when Firestore denies access',
      () {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollectionThrows(
          FirestorePermissionDeniedException(
            'read expertise',
            StateError('forbidden'),
            StackTrace.empty,
          ),
        );

        expect(
          repository.getAllExpertise,
          throwsA(isA<ExpertiseUnauthorizedException>()),
        );
      },
    );

    test(
      'should throw a parsing exception when the remote payload is invalid',
      () {
        cacheDelegateRepository.stubGetAllExpertiseThrows(
          const ExpertiseNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection({
          'experties': [
            {'image': 'https://example.com/flutter.png'},
          ],
        });

        expect(
          repository.getAllExpertise,
          throwsA(isA<ExpertiseParsingException>()),
        );
      },
    );

    test(
      'should replace the cached expertise with the remote one when refreshed',
      () async {
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository
          ..stubRefreshAllExpertise()
          ..stubCacheAllExpertise(expertiseList);

        await repository.refreshAllExpertise();

        verifyInOrder([
          () => cacheDelegateRepository.refreshAllExpertise(),
          () => cacheDelegateRepository.cacheAllExpertise(expertiseList),
        ]);
      },
    );

    test(
      'should keep the cached expertise when loading the remote one fails',
      () async {
        firestoreController.stubGetDocumentFromCollection(null);

        await expectLater(
          repository.refreshAllExpertise,
          throwsA(isA<ExpertiseNotFoundException>()),
        );
        verifyNever(() => cacheDelegateRepository.refreshAllExpertise());
      },
    );
  });
}
