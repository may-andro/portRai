import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/data/repository/asset_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
  final assetsJson = jsonEncode(
    createProjectAssetJson(projects: createProjectListJson()),
  );

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetProjectRepositoryImpl', () {
    late MockProjectRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late AssetProjectRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockProjectRepository();
      logReporter = MockLogReporter();
      repository = AssetProjectRepositoryImpl(
        appLocale,
        cacheDelegateRepository,
        mapper,
        logReporter,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', (message) async {
            final key = const StringCodec().decodeMessage(message);
            if (key == 'assets/dashboard/projects.json') {
              return assetResponse();
            }
            return null;
          });
    });

    tearDown(() {
      rootBundle.evict('assets/dashboard/projects.json');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMessageHandler('flutter/assets', null);
    });

    test(
      'should return cached projects when the cache already has data',
      () async {
        cacheDelegateRepository.stubGetProjects(projects);

        final result = await repository.getProjects();

        expect(result, projects);
        verify(() => cacheDelegateRepository.getProjects()).called(1);
        for (final project in projects) {
          verifyNever(() => cacheDelegateRepository.cacheProject(project));
        }
      },
    );

    test(
      'should load projects from assets and cache them when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        for (final project in projects) {
          cacheDelegateRepository.stubCacheProject(project);
        }

        final result = await repository.getProjects();

        expect(result, projects);
        for (final project in projects) {
          verify(() => cacheDelegateRepository.cacheProject(project)).called(1);
        }
      },
    );

    test(
      'should return a single project from assets when it is not cached',
      () async {
        final project = projects.first;
        cacheDelegateRepository.stubGetProjectThrows(
          id: project.id,
          error: const ProjectNotFoundException(),
        );
        for (final item in projects) {
          cacheDelegateRepository.stubCacheProject(item);
        }

        final result = await repository.getProject(project.id);

        expect(result, project);
        verify(
          () => logReporter.debug(
            'Project ${project.id} not found in cache, loading from assets',
            tag: 'AssetProjectRepositoryImpl',
          ),
        ).called(1);
      },
    );

    test(
      'should log the cache error and still load projects from assets when the cache throws a cache exception',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectCacheException(cause: 'db down'),
        );
        for (final project in projects) {
          cacheDelegateRepository.stubCacheProject(project);
        }

        final result = await repository.getProjects();

        expect(result, projects);
        verify(
          () => logReporter.error(
            'Cache error while getting projects: db down',
            tag: 'AssetProjectRepositoryImpl',
            stacktrace: any(named: 'stacktrace'),
          ),
        ).called(1);
      },
    );

    test(
      'should log and continue when caching projects loaded from assets fails',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        cacheDelegateRepository.stubCacheProjectThrows(
          project: projects.first,
          error: Exception('cache write failed'),
        );

        final result = await repository.getProjects();

        expect(result, projects);
        verify(
          () => logReporter.error(
            'Failed to cache projects from assets, continuing without caching.',
            tag: 'AssetProjectRepositoryImpl',
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
              if (key == 'assets/dashboard/projects.json') {
                return ByteData.sublistView(
                  Uint8List.fromList(utf8.encode('{invalid json')),
                );
              }
              return null;
            });
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );

        rootBundle.evict('assets/dashboard/projects.json');

        expect(repository.getProjects, throwsA(isA<ProjectParsingException>()));
      },
    );
  });
}
