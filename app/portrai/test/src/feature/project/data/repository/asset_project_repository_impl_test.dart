import 'dart:convert';

import 'package:core/core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/data/repository/asset_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/asset_source/domain/use_case/mock_get_asset_source_use_case.dart';
import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';
import '../../../../../mock/utility/fake_error_reporter.dart';
import '../../../../../mock/utility/mock_log_reporter.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ProjectMapper(appLocale: appLocale);
  final projects = [
    createProjectEntity(),
    createProjectEntity(id: 'portfolio-admin', title: 'Portfolio Admin'),
  ];
  final assetsJson = jsonEncode(
    createProjectAssetJson(projects: createProjectListJson()),
  );

  ByteData assetResponse() =>
      ByteData.sublistView(Uint8List.fromList(utf8.encode(assetsJson)));

  group('AssetProjectRepositoryImpl', () {
    late MockProjectRepository cacheDelegateRepository;
    late MockLogReporter logReporter;
    late FakeErrorReporter errorReporter;
    late MockGetAssetSourceUseCase getAssetSourceUseCase;
    late AssetProjectRepositoryImpl repository;

    setUp(() {
      cacheDelegateRepository = MockProjectRepository();
      logReporter = MockLogReporter();
      errorReporter = FakeErrorReporter();
      getAssetSourceUseCase = MockGetAssetSourceUseCase()
        ..stubCall(AssetSource.real);
      repository = AssetProjectRepositoryImpl(
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
            if (key == 'assets/dashboard/projects.json' ||
                key == 'assets/dashboard/projects.template.json') {
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
        verifyNever(() => cacheDelegateRepository.cacheProjects(projects));
      },
    );

    test(
      'should load projects from assets and cache them when the cache is empty',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        cacheDelegateRepository.stubCacheProjects(projects);

        final result = await repository.getProjects();

        expect(result, projects);
        verify(() => cacheDelegateRepository.cacheProjects(projects)).called(1);
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
        cacheDelegateRepository.stubCacheProjects(projects);

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
        cacheDelegateRepository.stubCacheProjects(projects);

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
      'should report the error and continue when caching projects loaded from assets fails',
      () async {
        cacheDelegateRepository.stubGetProjectsThrows(
          const ProjectNotFoundException(),
        );
        cacheDelegateRepository.stubCacheProjectsThrows(
          projects: projects,
          error: const ProjectCacheException(cause: 'cache write failed'),
        );

        final result = await repository.getProjects();

        expect(result, projects);
        final reportedError = errorReporter.reportedErrors.single;
        expect(reportedError.exception, isA<ProjectCacheException>());
        expect(reportedError.tag, 'AssetProjectRepositoryImpl');
      },
    );

    test(
      'should throw a parsing exception when the asset payload is invalid',
      () {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler('flutter/assets', (message) async {
              final key = const StringCodec().decodeMessage(message);
              if (key == 'assets/dashboard/projects.json' ||
                  key == 'assets/dashboard/projects.template.json') {
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

    test(
      'should load projects from assets without using the cache when the asset source is template',
      () async {
        getAssetSourceUseCase.stubCall(AssetSource.template);

        final result = await repository.getProjects();

        expect(result, projects);
        verifyZeroInteractions(cacheDelegateRepository);
      },
    );
  });
}
