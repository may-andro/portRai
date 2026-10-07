import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/domain/repository/mock_profile_repository.dart';
import '../../../../../mock/feature/profile/test_data/profile_test_data.dart';

void main() {
  final profile = createProfileEntity();

  group('GetProfileUseCase', () {
    late MockProfileRepository repository;
    late GetProfileUseCase useCase;

    setUp(() {
      repository = MockProfileRepository();
      useCase = GetProfileUseCase(repository);
    });

    test('should return the profile when the repository succeeds', () async {
      repository.stubGetProfile(profile);

      final result = await useCase();

      expect(result.isRight, isTrue);
      expect(result.right, profile);
    });

    final failures = <(Object, Type)>[
      (const ProfileNotFoundException(), ProfileNotFoundFailure),
      (const ProfileNetworkException(), ProfileNetworkFailure),
      (const ProfileParsingException(), ProfileDataFailure),
      (const ProfileCacheException(), ProfileDataFailure),
      (const ProfileUnauthorizedException(), ProfileUnauthorizedFailure),
      (Exception('unexpected'), ProfileUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubGetProfileThrows(error);

          final result = await useCase();

          expect(result.isLeft, isTrue);
          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
