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
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_openings/tracking/mock_job_openings_tracking_delegate.dart';

void main() {
  group('JobOpeningsBloc', () {
    late MockGetJobOpeningsUseCase getJobOpeningsUseCase;
    late MockSignOutUseCase signOutUseCase;
    late MockJobOpeningsTrackingDelegate trackingDelegate;

    final jobOpening = jobOpeningEntityFixture();

    setUp(() {
      getJobOpeningsUseCase = MockGetJobOpeningsUseCase()
        ..stubCall(Right([jobOpening]));
      signOutUseCase = MockSignOutUseCase();
      trackingDelegate = MockJobOpeningsTrackingDelegate();
    });

    JobOpeningsBloc buildBloc() => JobOpeningsBloc(
      getJobOpeningsUseCase,
      signOutUseCase,
      trackingDelegate,
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should load the openings when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsStartedEvent()),
      expect: () => [
        const JobOpeningsState(),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
        ),
      ],
      verify: (_) => verify(() => trackingDelegate.trackScreenView()).called(1),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should show the load failure when the openings fail to load',
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
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should reload the openings when retry is clicked',
      seed: () => const JobOpeningsState(
        status: JobOpeningsStatus.failed,
        loadFailure: GetJobOpeningsNetworkFailure(),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsRetryClickEvent()),
      expect: () => [
        const JobOpeningsState(),
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          jobOpenings: [jobOpening],
        ),
      ],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should keep the search when the search text changes',
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsSearchChangedEvent('acme')),
      expect: () => const [JobOpeningsState(searchQuery: 'acme')],
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should select the filter and track it when an unselected filter is '
      'clicked',
      seed: () => const JobOpeningsState(filters: {JobOpeningsFilter.flutter}),
      build: buildBloc,
      act: (bloc) =>
          bloc.add(const JobOpeningsFilterClickEvent(JobOpeningsFilter.recent)),
      expect: () => const [
        JobOpeningsState(
          filters: {JobOpeningsFilter.flutter, JobOpeningsFilter.recent},
        ),
      ],
      verify: (_) => verify(
        () => trackingDelegate.trackFilterSelection('recent'),
      ).called(1),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should deselect the filter without tracking when a selected filter is '
      'clicked',
      seed: () => const JobOpeningsState(filters: {JobOpeningsFilter.flutter}),
      build: buildBloc,
      act: (bloc) => bloc.add(
        const JobOpeningsFilterClickEvent(JobOpeningsFilter.flutter),
      ),
      expect: () => const [JobOpeningsState()],
      verify: (_) =>
          verifyNever(() => trackingDelegate.trackFilterSelection(any())),
    );

    blocTest<JobOpeningsBloc, JobOpeningsState>(
      'should clear the search and the filters when clear is clicked',
      seed: () => const JobOpeningsState(
        searchQuery: 'acme',
        filters: {JobOpeningsFilter.flutter},
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningsClearFiltersClickEvent()),
      expect: () => const [JobOpeningsState()],
      verify: (_) =>
          verify(() => trackingDelegate.trackClearFiltersClick()).called(1),
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
      act: (bloc) => bloc.add(
        const JobOpeningClickEvent(
          label: 'job_opening_card',
          jobOpeningId: 'job-1',
        ),
      ),
      expect: () => const <JobOpeningsState>[],
      verify: (_) => verify(
        () => trackingDelegate.trackJobOpeningClick(
          label: 'job_opening_card',
          jobOpeningId: 'job-1',
        ),
      ).called(1),
    );
  });

  group('JobOpeningsState.visibleJobOpenings', () {
    final now = DateTime(2026, 10, 21, 9);
    final flutterJob = jobOpeningEntityFixture(
      id: 'flutter',
      score: 85,
      publishedAt: DateTime(2026, 10, 20),
    );
    final androidContract = jobOpeningEntityFixture(
      id: 'android',
      title: 'Android Engineer (Contract)',
      company: 'Globex',
      tags: [],
      matchedSkills: ['Kotlin'],
      score: 72,
    );
    final iosJob = jobOpeningEntityFixture(
      id: 'ios',
      title: 'iOS Engineer',
      tags: [],
      matchedSkills: ['Swift'],
      score: 65,
    );
    final jobOpenings = [flutterJob, androidContract, iosJob];

    List<String> visibleIds(JobOpeningsState state) => state
        .visibleJobOpenings(now)
        .map((jobOpening) => jobOpening.id)
        .toList();

    test('should show every opening when nothing narrows the list', () {
      expect(visibleIds(JobOpeningsState(jobOpenings: jobOpenings)), [
        'flutter',
        'android',
        'ios',
      ]);
    });

    test('should match every search word in any order when searching', () {
      expect(
        visibleIds(
          JobOpeningsState(
            jobOpenings: jobOpenings,
            searchQuery: '  kotlin GLOBEX ',
          ),
        ),
        ['android'],
      );
    });

    test('should widen within a group when two platforms are selected', () {
      expect(
        visibleIds(
          JobOpeningsState(
            jobOpenings: jobOpenings,
            filters: const {JobOpeningsFilter.android, JobOpeningsFilter.ios},
          ),
        ),
        ['android', 'ios'],
      );
    });

    test('should narrow across groups when a platform and a work type are '
        'selected', () {
      expect(
        visibleIds(
          JobOpeningsState(
            jobOpenings: jobOpenings,
            filters: const {
              JobOpeningsFilter.flutter,
              JobOpeningsFilter.android,
              JobOpeningsFilter.contract,
            },
          ),
        ),
        ['android'],
      );
    });

    test('should keep strong and recent openings when those filters are '
        'selected', () {
      expect(
        visibleIds(
          JobOpeningsState(
            jobOpenings: jobOpenings,
            filters: const {
              JobOpeningsFilter.strongFit,
              JobOpeningsFilter.recent,
            },
          ),
        ),
        ['flutter'],
      );
    });
  });
}
