import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/job_opening/domain/repository/mock_job_opening_repository.dart';

void main() {
  group('IsJobSearchEnabledUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockJobOpeningRepository jobOpeningRepository;

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(AuthUserEntity(id: 'owner-uid', email: null)));
      jobOpeningRepository = MockJobOpeningRepository();
    });

    IsJobSearchEnabledUseCase buildUseCase() =>
        IsJobSearchEnabledUseCase(getSignedInUserUseCase, jobOpeningRepository);

    for (final isEnabled in [true, false]) {
      test('should return $isEnabled when the signed-in user has job search '
          'set to $isEnabled', () async {
        jobOpeningRepository.stubIsJobSearchEnabled(isEnabled);

        final isJobSearchEnabledEither = await buildUseCase()();

        expect(isJobSearchEnabledEither.right, isEnabled);
        verify(
          () => jobOpeningRepository.isJobSearchEnabled('owner-uid'),
        ).called(1);
      });
    }

    test(
      'should return a signed-out failure when nobody is signed in',
      () async {
        getSignedInUserUseCase.stubCall(const Right(null));

        final isJobSearchEnabledEither = await buildUseCase()();

        expect(
          isJobSearchEnabledEither.left,
          isA<IsJobSearchEnabledSignedOutFailure>(),
        );
      },
    );

    test(
      'should return an unknown failure when the repository throws',
      () async {
        jobOpeningRepository.stubIsJobSearchEnabledThrows(
          const JobOpeningNetworkException(),
        );

        final isJobSearchEnabledEither = await buildUseCase()();

        expect(
          isJobSearchEnabledEither.left,
          isA<IsJobSearchEnabledUnknownFailure>(),
        );
      },
    );
  });
}
