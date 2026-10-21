import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../mock/feature/job_opening/domain/repository/mock_job_opening_repository.dart';

void main() {
  group('GetJobOpeningsUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockJobOpeningRepository jobOpeningRepository;

    const signedInUser = AuthUserEntity(id: 'owner-uid', email: null);

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(signedInUser));
      jobOpeningRepository = MockJobOpeningRepository();
    });

    GetJobOpeningsUseCase buildUseCase() =>
        GetJobOpeningsUseCase(getSignedInUserUseCase, jobOpeningRepository);

    test('should return the openings best fit first and then newest first '
        'when a user is signed in', () async {
      final olderBestFit = jobOpeningEntityFixture(
        id: 'older-best',
        score: 90,
        publishedAt: DateTime.utc(2026, 10, 10),
      );
      final newerBestFit = jobOpeningEntityFixture(
        id: 'newer-best',
        score: 90,
        publishedAt: DateTime.utc(2026, 10, 15),
      );
      final weakerFit = jobOpeningEntityFixture(id: 'weaker', score: 65);
      jobOpeningRepository.stubGetJobOpenings([
        weakerFit,
        olderBestFit,
        newerBestFit,
      ]);

      final jobOpeningsEither = await buildUseCase()();

      expect(jobOpeningsEither.right.map((jobOpening) => jobOpening.id), [
        'newer-best',
        'older-best',
        'weaker',
      ]);
      verify(() => jobOpeningRepository.getJobOpenings('owner-uid')).called(1);
    });

    test('should return a signed-out failure without reading when nobody is '
        'signed in', () async {
      getSignedInUserUseCase.stubCall(const Right(null));

      final jobOpeningsEither = await buildUseCase()();

      expect(jobOpeningsEither.left, isA<GetJobOpeningsSignedOutFailure>());
      verifyNever(() => jobOpeningRepository.getJobOpenings(any()));
    });

    test('should return an unknown failure with the auth failure as its cause '
        'when the user cannot be read', () async {
      const authFailure = GetSignedInUserUnknownFailure();
      getSignedInUserUseCase.stubCall(const Left(authFailure));

      final jobOpeningsEither = await buildUseCase()();

      expect(jobOpeningsEither.left, isA<GetJobOpeningsUnknownFailure>());
      expect(jobOpeningsEither.left.cause, authFailure);
    });

    for (final (exception, failureMatcher) in [
      (
        const JobOpeningPermissionDeniedException(),
        isA<GetJobOpeningsPermissionDeniedFailure>(),
      ),
      (const JobOpeningNetworkException(), isA<GetJobOpeningsNetworkFailure>()),
      (const JobOpeningUnknownException(), isA<GetJobOpeningsUnknownFailure>()),
    ]) {
      test('should return the matching failure when the repository throws '
          '${exception.runtimeType}', () async {
        jobOpeningRepository.stubGetJobOpeningsThrows(exception);

        final jobOpeningsEither = await buildUseCase()();

        expect(jobOpeningsEither.left, failureMatcher);
      });
    }
  });
}
