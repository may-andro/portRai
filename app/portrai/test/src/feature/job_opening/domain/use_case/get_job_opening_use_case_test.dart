import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/auth/domain/use_case/mock_get_signed_in_user_use_case.dart';
import '../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../mock/feature/job_opening/domain/repository/mock_job_opening_repository.dart';

void main() {
  group('GetJobOpeningUseCase', () {
    late MockGetSignedInUserUseCase getSignedInUserUseCase;
    late MockJobOpeningRepository jobOpeningRepository;

    setUp(() {
      getSignedInUserUseCase = MockGetSignedInUserUseCase()
        ..stubCall(const Right(AuthUserEntity(id: 'owner-uid', email: null)));
      jobOpeningRepository = MockJobOpeningRepository();
    });

    GetJobOpeningUseCase buildUseCase() =>
        GetJobOpeningUseCase(getSignedInUserUseCase, jobOpeningRepository);

    test(
      'should return the opening of the signed-in user when it exists',
      () async {
        final jobOpening = jobOpeningEntityFixture();
        jobOpeningRepository.stubGetJobOpening(jobOpening);

        final jobOpeningEither = await buildUseCase()('job-1');

        expect(jobOpeningEither.right, jobOpening);
        verify(
          () => jobOpeningRepository.getJobOpening(
            userId: 'owner-uid',
            id: 'job-1',
          ),
        ).called(1);
      },
    );

    test(
      'should return a signed-out failure when nobody is signed in',
      () async {
        getSignedInUserUseCase.stubCall(const Right(null));

        final jobOpeningEither = await buildUseCase()('job-1');

        expect(jobOpeningEither.left, isA<GetJobOpeningSignedOutFailure>());
      },
    );

    test(
      'should return a not found failure when the opening is gone',
      () async {
        jobOpeningRepository.stubGetJobOpeningThrows(
          const JobOpeningNotFoundException(),
        );

        final jobOpeningEither = await buildUseCase()('job-1');

        expect(jobOpeningEither.left, isA<GetJobOpeningNotFoundFailure>());
      },
    );

    test('should return a network failure when the repository has no '
        'connection', () async {
      jobOpeningRepository.stubGetJobOpeningThrows(
        const JobOpeningNetworkException(),
      );

      final jobOpeningEither = await buildUseCase()('job-1');

      expect(jobOpeningEither.left, isA<GetJobOpeningNetworkFailure>());
    });
  });
}
