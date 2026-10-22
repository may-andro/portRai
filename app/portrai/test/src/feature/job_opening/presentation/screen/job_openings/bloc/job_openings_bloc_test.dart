import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/auth/domain/use_case/mock_sign_out_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_get_job_openings_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_is_job_search_enabled_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_set_job_search_enabled_use_case.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_openings/tracking/mock_job_openings_tracking_delegate.dart';

void main() {
  group('JobOpeningsBloc', () {
    late MockGetJobOpeningsUseCase getJobOpeningsUseCase;
    late MockIsJobSearchEnabledUseCase isJobSearchEnabledUseCase;
    late MockSetJobSearchEnabledUseCase setJobSearchEnabledUseCase;
    late MockSignOutUseCase signOutUseCase;
    late MockJobOpeningsTrackingDelegate trackingDelegate;

    final jobOpening = jobOpeningEntityFixture();

    setUp(() {
      getJobOpeningsUseCase = MockGetJobOpeningsUseCase()
        ..stubCall(Right([jobOpening]));
      isJobSearchEnabledUseCase = MockIsJobSearchEnabledUseCase()
        ..stubCall(const Right(true));
      setJobSearchEnabledUseCase = MockSetJobSearchEnabledUseCase();
      signOutUseCase = MockSignOutUseCase();
      trackingDelegate = MockJobOpeningsTrackingDelegate();
    });

    JobOpeningsBloc buildBloc() => JobOpeningsBloc(
      getJobOpeningsUseCase,
      isJobSearchEnabledUseCase,
      setJobSearchEnabledUseCase,
      signOutUseCase,
      trackingDelegate,
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should load the openings and the job search setting when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsStartedEvent()),
      expect: () => [
        const JobOpeningsState(),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
        ),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
          isJobSearchEnabled: true,
        ),
      ],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should show the load failure and keep the switch when the openings '
      'fail to load',
      setUp: () => getJobOpeningsUseCase.stubCall(
        const Left(GetJobOpeningsNetworkFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsStartedEvent()),
      expect: () => const [
        JobOpeningsState(),
        JobOpeningsState(
          status: JobOpeningsStatus.failed,
          loadFailure: GetJobOpeningsNetworkFailure(),
        ),
        JobOpeningsState(
          status: JobOpeningsStatus.failed,
          loadFailure: GetJobOpeningsNetworkFailure(),
          isJobSearchEnabled: true,
        ),
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should hide the switch when the job search setting cannot be read',
      setUp: () => isJobSearchEnabledUseCase.stubCall(
        const Left(IsJobSearchEnabledUnknownFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsStartedEvent()),
      expect: () => [
        const JobOpeningsState(),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
        ),
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should reload the openings when retry is clicked',
      seed: () => const JobOpeningsState(
        status: JobOpeningsStatus.failed,
        loadFailure: GetJobOpeningsNetworkFailure(),
        isJobSearchEnabled: true,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsRetryClickEvent()),
      expect: () => [
        const JobOpeningsState(isJobSearchEnabled: true),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
          isJobSearchEnabled: true,
        ),
      ],
      verify: (_) => verifyNever(() => isJobSearchEnabledUseCase()),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should save and show the new setting when the switch is toggled',
      setUp: () => setJobSearchEnabledUseCase.stubCall(const Right(null)),
      seed: () => const JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        isJobSearchEnabled: true,
      ),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const JobSearchToggleClickEvent(isEnabled: false)),
      expect: () => const [
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isJobSearchEnabled: true,
          isUpdatingJobSearch: true,
        ),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isJobSearchEnabled: false,
        ),
      ],
      verify: (_) {
        verify(() => setJobSearchEnabledUseCase(false)).called(1);
        verify(
          () => trackingDelegate.trackJobSearchToggle(isEnabled: false),
        ).called(1);
      },
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should keep the old setting and show the failure when saving fails',
      setUp: () => setJobSearchEnabledUseCase.stubCall(
        const Left(SetJobSearchEnabledNetworkFailure()),
      ),
      seed: () => const JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        isJobSearchEnabled: true,
      ),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const JobSearchToggleClickEvent(isEnabled: false)),
      expect: () => const [
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isJobSearchEnabled: true,
          isUpdatingJobSearch: true,
        ),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isJobSearchEnabled: true,
          actionFailure: SetJobSearchEnabledNetworkFailure(),
        ),
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should mark the user signed out when sign out succeeds',
      setUp: () => signOutUseCase.stubCall(const Right(null)),
      seed: () => const JobOpeningsState(status: JobOpeningsStatus.loaded),
      build: buildBloc,
      act: (bloc) => bloc.add(const SignOutClickEvent()),
      expect: () => const [
        JobOpeningsState(status: JobOpeningsStatus.loaded, isSigningOut: true),
        JobOpeningsState(status: JobOpeningsStatus.loaded, isSignedOut: true),
      ],
      verify: (_) =>
          verify(() => trackingDelegate.trackSignOutClick()).called(1),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should show the failure when sign out fails',
      setUp: () => signOutUseCase.stubCall(const Left(SignOutNetworkFailure())),
      seed: () => const JobOpeningsState(status: JobOpeningsStatus.loaded),
      build: buildBloc,
      act: (bloc) => bloc.add(const SignOutClickEvent()),
      expect: () => const [
        JobOpeningsState(status: JobOpeningsStatus.loaded, isSigningOut: true),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          actionFailure: SignOutNetworkFailure(),
        ),
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should track the click when an opening is clicked',
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningClickEvent()),
      expect: () => const <JobOpeningsState>[],
      verify: (_) =>
          verify(() => trackingDelegate.trackJobOpeningClick()).called(1),
    );
  });
}
