import 'package:cache/cache.dart';
import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/data/mapper/project_mapper.dart';
import 'package:portrai/src/feature/project/data/model/project_model.dart';
import 'package:portrai/src/feature/project/data/repository/cache_project_repository_impl.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/data/cache/mock_project_cache.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  const localeCode = 'en';
  final appLocale = AppLocale(localeCode);
  final mapper = ProjectMapper(appLocale: appLocale);
  final project = createProjectEntity();
  final model = createProjectModel();

  group('CacheProjectRepositoryImpl', () {
    late MockProjectCache projectCache;
    late CacheProjectRepositoryImpl repository;

    setUpAll(() {
      registerFallbackValue(model);
    });

    setUp(() {
      projectCache = MockProjectCache();
      repository = CacheProjectRepositoryImpl(projectCache, mapper, appLocale);
    });

    test('should return mapped projects when cached records exist', () async {
      projectCache.stubQuery(
        conditions: {'locale': localeCode},
        result: [model],
      );

      final result = await repository.getProjects();

      expect(result, [project]);
    });

    test(
      'should throw a not found exception when the cache has no projects',
      () {
        projectCache.stubQuery(conditions: {'locale': localeCode}, result: []);

        expect(
          repository.getProjects,
          throwsA(isA<ProjectNotFoundException>()),
        );
      },
    );

    test(
      'should return the cached project when it exists for the locale',
      () async {
        projectCache.stubGet(
          conditions: {'id': project.id, 'locale': localeCode},
          result: model,
        );

        final result = await repository.getProject(project.id);

        expect(result, project);
      },
    );

    test(
      'should throw a not found exception when the cached project is missing',
      () {
        projectCache.stubGet(
          conditions: {'id': project.id, 'locale': localeCode},
          result: null,
        );

        expect(
          () => repository.getProject(project.id),
          throwsA(isA<ProjectNotFoundException>()),
        );
      },
    );

    test('should cache the mapped project when caching succeeds', () async {
      projectCache.stubPut();

      await repository.cacheProject(project);

      final captured =
          verify(() => projectCache.put(captureAny())).captured.single
              as ProjectModel;
      expect(captured.toJson(), model.toJson());
    });

    test(
      'should throw a cache exception when the database is unavailable while caching',
      () {
        projectCache.stubPutThrows(
          DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(
          () => repository.cacheProject(project),
          throwsA(isA<ProjectCacheException>()),
        );
      },
    );

    test(
      'should throw a cache exception when the database is unavailable while reading the project list',
      () {
        projectCache.stubQueryThrows(
          conditions: {'locale': localeCode},
          error: DBNotInitialisedException(cause: Exception('db init failed')),
        );

        expect(repository.getProjects, throwsA(isA<ProjectCacheException>()));
      },
    );
  });
}
