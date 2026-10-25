import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';

void main() {
  group('RefreshAllExpertiseUseCase', () {
    late MockExpertiseRepository repository;
    late RefreshAllExpertiseUseCase useCase;

    setUp(() {
      repository = MockExpertiseRepository();
      useCase = RefreshAllExpertiseUseCase(repository);
    });

    test(
      'should succeed when the repository refreshes the expertise',
      () async {
        repository.stubRefreshAllExpertise();

        final result = await useCase();

        expect(result.isRight, isTrue);
      },
    );

    final failures = <(Object, Type)>[
      (const ExpertiseNetworkException(), RefreshAllExpertiseNetworkFailure),
      (
        const ExpertiseUnauthorizedException(),
        RefreshAllExpertiseNetworkFailure,
      ),
      (const ExpertiseNotFoundException(), RefreshAllExpertiseDataFailure),
      (const ExpertiseParsingException(), RefreshAllExpertiseDataFailure),
      (const ExpertiseCacheException(), RefreshAllExpertiseDataFailure),
      (Exception('unexpected'), RefreshAllExpertiseUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshAllExpertiseThrows(error);

          final result = await useCase();

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
