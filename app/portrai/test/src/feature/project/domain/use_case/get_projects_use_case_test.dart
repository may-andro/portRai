import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';
import '../../../../../mock/feature/project/test_data/project_test_data.dart';

void main() {
  final project = createProjectEntity();

  group('GetProjectsUseCase', () {
    late MockProjectRepository repository;
    late GetProjectsUseCase useCase;

    setUp(() {
      repository = MockProjectRepository();
      useCase = GetProjectsUseCase(repository);
    });

    test('should return all projects when the repository succeeds', () async {
      repository.stubGetProjects([project]);

      final result = await useCase();

      expect(result.isRight, isTrue);
      expect(result.right, [project]);
    });

    final failures = <(Object, Type)>[
      (const ProjectNotFoundException(), ProjectNotFoundFailure),
      (const ProjectNetworkException(), ProjectNetworkFailure),
      (const ProjectParsingException(), ProjectDataFailure),
      (const ProjectCacheException(), ProjectDataFailure),
      (const ProjectUnauthorizedException(), ProjectUnauthorizedFailure),
      (Exception('unexpected'), ProjectUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetProjectsThrows(error);

          final result = await useCase();

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
