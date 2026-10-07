import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final project = createProjectEntity();

  group('GetProjectUseCase', () {
    late MockProjectRepository repository;
    late GetProjectUseCase useCase;

    setUp(() {
      repository = MockProjectRepository();
      useCase = GetProjectUseCase(repository);
    });

    test(
      'should return the requested project when the repository succeeds',
      () async {
        repository.stubGetProject(id: project.id, project: project);

        final result = await useCase(project.id);

        expect(result.isRight, isTrue);
        expect(result.right, project);
      },
    );

    final failures = <(Object, Type)>[
      (const ProjectNotFoundException(), GetProjectNotFoundFailure),
      (const ProjectNetworkException(), GetProjectNetworkFailure),
      (const ProjectParsingException(), GetProjectDataFailure),
      (const ProjectCacheException(), GetProjectDataFailure),
      (const ProjectUnauthorizedException(), GetProjectUnauthorizedFailure),
      (Exception('unexpected'), GetProjectUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetProjectThrows(id: project.id, error: error);

          final result = await useCase(project.id);

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
