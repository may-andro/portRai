import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/experience/data/repository/remote_experience_repository_impl.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

import '../../../../../mock/feature/experience/domain/repository/mock_experience_repository.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ExperienceMapper(appLocale: appLocale);
  final experiences = [
    ExperienceEntity(
      company: 'Acme',
      position: 'Engineer',
      location: 'Amsterdam',
      startDate: DateTime(2024),
      endDate: null,
      current: true,
      employmentType: 'Full-time',
      description: 'Builds products',
      longDescription: 'Builds products for customers',
      responsibilities: const ['Coding'],
      achievements: const ['Shipped'],
      technologies: const ['Dart'],
      companyLogo: 'acme.png',
      url: null,
      id: 'acme-engineer',
    ),
  ];
  final firestoreDocument = {
    'experiences': [for (final e in experiences) mapper.from(e).toJson()],
  };

  group('RemoteExperienceRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockExperienceRepository cacheDelegateRepository;
    late RemoteExperienceRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheDelegateRepository = MockExperienceRepository();
      repository = RemoteExperienceRepositoryImpl(
        firestoreController,
        appLocale,
        cacheDelegateRepository,
        mapper,
        MockLogReporter(),
        FakeErrorReporter(),
      );
    });

    test(
      'should replace the cached experiences with the remote ones when refreshed',
      () async {
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository
          ..stubRefreshExperiences()
          ..stubCacheExperiences(experiences);

        await repository.refreshExperiences();

        verify(
          () => firestoreController.getDocumentFromCollection(
            'experiences',
            localeCode,
          ),
        ).called(1);
        verifyInOrder([
          () => cacheDelegateRepository.refreshExperiences(),
          () => cacheDelegateRepository.cacheExperiences(experiences),
        ]);
      },
    );

    test(
      'should keep the cached experiences when loading the remote ones fails',
      () async {
        firestoreController.stubGetDocumentFromCollection(null);

        await expectLater(
          repository.refreshExperiences,
          throwsA(isA<ExperienceNotFoundException>()),
        );
        verifyNever(() => cacheDelegateRepository.refreshExperiences());
      },
    );
  });
}
