import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

import '../../../../../mock/feature/project/domain/repository/mock_project_repository.dart';

void main() {
  group('RefreshProjectsUseCase', () {
    late MockProjectRepository repository;
    late RefreshProjectsUseCase useCase;

    setUp(() {
      repository = MockProjectRepository();
      useCase = RefreshProjectsUseCase(repository);
    });

    test('should succeed when the repository refreshes the projects', () async {
      repository.stubRefreshProjects();

      final result = await useCase();

      expect(result.isRight, isTrue);
    });

    final failures = <(Object, Type)>[
      (const ProjectNetworkException(), RefreshProjectsNetworkFailure),
      (const ProjectUnauthorizedException(), RefreshProjectsNetworkFailure),
      (const ProjectNotFoundException(), RefreshProjectsDataFailure),
      (const ProjectParsingException(), RefreshProjectsDataFailure),
      (const ProjectCacheException(), RefreshProjectsDataFailure),
      (Exception('unexpected'), RefreshProjectsUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshProjectsThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
