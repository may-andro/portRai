import 'package:core/core.dart';
import 'package:firebase/firebase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/data/repository/remote_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ProjectMapper(appLocale: appLocale);
  final projects = [
    createProjectEntity(),
    createProjectEntity(
      id: 'portfolio-admin',
      title: 'Portfolio Admin',
      website: null,
      github: null,
    ),
  ];
  final firestoreDocument = {'projects': createProjectListJson()};

  group('RemoteProjectRepositoryImpl', () {
    late MockFbFirestoreController firestoreController;
    late MockProjectRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late RemoteProjectRepositoryImpl repository;

    setUp(() {
      firestoreController = MockFbFirestoreController();
      cacheDelegateRepository = MockProjectRepository();
      logReporter = MockLogReporter();
      repository = RemoteProjectRepositoryImpl(
        firestoreController,
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
    });

    test(
      'should return cached projects when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetProjects(projects);

        final result = await repository.getProjects();

        expect(result, projects);
        verify(() => cacheDelegateRepository.getProjects()).called(1);
        verifyNever(
          () => firestoreController.getDocumentFromCollection(any(), any()),
        );
      },
    );

    test(
      'should load projects from remote and cache them when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        for (final project in projects) {
          cacheDelegateRepository.stubCacheProject(project);
        }

        final result = await repository.getProjects();

        expect(result, projects);
        verify(
          () => firestoreController.getDocumentFromCollection(
            'projects',
            localeCode,
          ),
        ).called(1);
        for (final project in projects) {
          verify(() => cacheDelegateRepository.cacheProject(project)).called(1);
        }
      },
    );

    test(
      'should return a single project from remote when it is not cached',
      () async {
        final project = projects.first;
        cacheDelegateRepository.stubGetProjectThrows(
          id: project.id,
          error: const ProjectNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        for (final item in projects) {
          cacheDelegateRepository.stubCacheProject(item);
        }

        final result = await repository.getProject(project.id);

        expect(result, project);
        verify(
          () => logReporter.debug(
            'Project ${project.id} not found in cache, loading from remote',
            tag: 'RemoteProjectRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load projects from remote when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectCacheException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        for (final project in projects) {
          cacheDelegateRepository.stubCacheProject(project);
        }

        final result = await repository.getProjects();

        expect(result, projects);
        verify(
          () => logReporter.error(
            'Cache error while getting projects, loading from remote instead.',
            tag: 'RemoteProjectRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log and continue when caching projects loaded from remote fails',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection(firestoreDocument);
        cacheDelegateRepository.stubCacheProjectThrows(
          project: projects.first,
          error: Exception('cache write failed'),
        );

        final result = await repository.getProjects();

        expect(result, projects);
        verify(
          () => logReporter.error(
            'Failed to cache projects from remote, continuing without caching.',
            tag: 'RemoteProjectRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should throw an unauthorized exception when Firestore denies access',
      () {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollectionThrows(
          FirestorePermissionDeniedException(
            'read projects',
            StateError('forbidden'),
            StackTrace.empty,
          ),
        );

        expect(
          repository.getProjects,
          throwsA(isA<ProjectUnauthorizedException>()),
        );
      },
    );

    test(
      'should throw a parsing exception when the remote payload is invalid',
      () {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        firestoreController.stubGetDocumentFromCollection({
          'projects': [
            {'title': 'broken'},
          ],
        });

        expect(
          repository.getProjects(),
          throwsA(isA<ProjectParsingException>()),
        );
      },
    );
  });
}
