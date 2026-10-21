import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/job_opening/domain/repository/mock_job_opening_repository.dart';

void main() {
  group('SetJobSearchEnabledUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockJobOpeningRepository jobOpeningRepository;

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(AuthUserEntity(id: 'owner-uid', email: null)));
      jobOpeningRepository = MockJobOpeningRepository();
    });

    SetJobSearchEnabledUseCase buildUseCase() => SetJobSearchEnabledUseCase(
      getSignedInUserUseCase,
      jobOpeningRepository,
    );

    test(
      'should save the setting for the signed-in user when called',
      () async {
        jobOpeningRepository.stubSetJobSearchEnabled();

        final setJobSearchEnabledEither = await buildUseCase()(true);

        expect(setJobSearchEnabledEither.isRight, isTrue);
        verify(
          () => jobOpeningRepository.setJobSearchEnabled(
            userId: 'owner-uid',
            isEnabled: true,
          ),
        ).called(1);
      },
    );

    test('should return a signed-out failure without writing when nobody is '
        'signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final setJobSearchEnabledEither = await buildUseCase()(true);

      expect(
        setJobSearchEnabledEither.left,
        isA<SetJobSearchEnabledSignedOutFailure>(),
      );
      verifyNever(
        () => jobOpeningRepository.setJobSearchEnabled(
          userId: any(named: 'userId'),
          isEnabled: any(named: 'isEnabled'),
        ),
      );
    });

    for (final (exception, failureMatcher) in [
      (
        const JobOpeningPermissionDeniedException(),
        isA<SetJobSearchEnabledPermissionDeniedFailure>(),
      ),
      (
        const JobOpeningNetworkException(),
        isA<SetJobSearchEnabledNetworkFailure>(),
      ),
      (
        const JobOpeningUnknownException(),
        isA<SetJobSearchEnabledUnknownFailure>(),
      ),
    ]) {
      test('should return the matching failure when the repository throws '
          '${exception.runtimeType}', () async {
        jobOpeningRepository.stubSetJobSearchEnabledThrows(exception);

        final setJobSearchEnabledEither = await buildUseCase()(false);

        expect(setJobSearchEnabledEither.left, failureMatcher);
      });
    }
  });
}
