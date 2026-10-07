import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

import '../../../../../mock/feature/expertise/domain/repository/mock_expertise_repository.dart';

void main() {
  const expertise = ExpertiseEntity(
    image: 'https://example.com/flutter.png',
    title: 'Flutter Development',
    skills: ['Flutter SDK', 'State Management'],
  );

  group('GetAllExpertiseUseCase', () {
    late MockExpertiseRepository repository;
    late GetAllExpertiseUseCase useCase;

    setUp(() {
      repository = MockExpertiseRepository();
      useCase = GetAllExpertiseUseCase(repository);
    });

    test('should return all expertise when the repository succeeds', () async {
      repository.stubGetAllExpertise([expertise]);

      final result = await useCase();

      expect(result.isRight, isTrue);
      expect(result.right, [expertise]);
    });

    final failures = <(Object, Type)>[
      (const ExpertiseNotFoundException(), ExpertiseNotFoundFailure),
      (const ExpertiseNetworkException(), ExpertiseNetworkFailure),
      (const ExpertiseParsingException(), ExpertiseDataFailure),
      (const ExpertiseCacheException(), ExpertiseDataFailure),
      (const ExpertiseUnauthorizedException(), ExpertiseUnauthorizedFailure),
      (Exception('unexpected'), ExpertiseUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetAllExpertiseThrows(error);

          final result = await useCase();

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
