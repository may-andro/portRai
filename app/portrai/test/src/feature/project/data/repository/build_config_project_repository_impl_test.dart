import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/data/repository/build_config_project_repository_impl.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final project = createProjectEntity();

  for (final environment in BuildEnvironment.values) {
    group('BuildConfigProjectRepositoryImpl ($environment)', () {
      late MockProjectRepository remote;
      late MockProjectRepository asset;
      late BuildConfigProjectRepositoryImpl repository;
      late MockProjectRepository selected;
      late MockProjectRepository unselected;

      setUp(() {
        remote = MockProjectRepository();
        asset = MockProjectRepository();
        repository = BuildConfigProjectRepositoryImpl(
          BuildConfig(buildEnvironment: environment),
          remote,
          asset,
        );
        selected = environment == BuildEnvironment.prod ? remote : asset;
        unselected = environment == BuildEnvironment.prod ? asset : remote;
      });

      test(
        'should delegate project reads to the selected source when requested',
        () async {
          selected.stubGetProject(id: project.id, project: project);

          expect(await repository.getProject(project.id), project);
          verify(() => selected.getProject(project.id)).called(1);
          verifyNever(() => unselected.getProject(project.id));
        },
      );

      test(
        'should delegate list reads to the selected source when requested',
        () async {
          selected.stubGetProjects([project]);

          expect(await repository.getProjects(), [project]);
          verify(() => selected.getProjects()).called(1);
          verifyNever(() => unselected.getProjects());
        },
      );

      test(
        'should delegate cache writes to the selected source when requested',
        () async {
          selected.stubCacheProject(project);

          await repository.cacheProject(project);

          verify(() => selected.cacheProject(project)).called(1);
          verifyNever(() => unselected.cacheProject(project));
        },
      );
    });
  }
}
