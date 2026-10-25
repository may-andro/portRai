import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

import '../../../../../mock/feature/profile/domain/repository/mock_profile_repository.dart';

void main() {
  group('RefreshProfileUseCase', () {
    late MockProfileRepository repository;
    late RefreshProfileUseCase useCase;

    setUp(() {
      repository = MockProfileRepository();
      useCase = RefreshProfileUseCase(repository);
    });

    test('should succeed when the repository refreshes the profile', () async {
      repository.stubRefreshProfile();

      final result = await useCase();

      expect(result.isRight, isTrue);
    });

    final failures = <(Object, Type)>[
      (const ProfileNetworkException(), RefreshProfileNetworkFailure),
      (const ProfileUnauthorizedException(), RefreshProfileNetworkFailure),
      (const ProfileNotFoundException(), RefreshProfileDataFailure),
      (const ProfileParsingException(), RefreshProfileDataFailure),
      (const ProfileCacheException(), RefreshProfileDataFailure),
      (Exception('unexpected'), RefreshProfileUnknownFailure),
    ];

    for (final (error, failureType) in failures) {
      test(
        'should return $failureType when the repository throws $error',
        () async {
          repository.stubRefreshProfileThrows(error);

          final result = await useCase();

          expect(result.left.runtimeType, failureType);
          expect(result.left.cause, same(error));
        },
      );
    }
  });
}
