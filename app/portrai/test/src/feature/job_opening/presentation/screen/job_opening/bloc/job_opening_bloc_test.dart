import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_get_job_opening_use_case.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_opening/tracking/mock_job_opening_tracking_delegate.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeOpenExternalUrlParam()));

  group('JobOpeningBloc', () {
    late MockGetJobOpeningUseCase getJobOpeningUseCase;
    late MockOpenExternalUrlUseCase openExternalUrlUseCase;
    late MockJobOpeningTrackingDelegate trackingDelegate;

    final jobOpening = jobOpeningEntityFixture();

    setUp(() {
      getJobOpeningUseCase = MockGetJobOpeningUseCase()
        ..stubCall(Right(jobOpening));
      openExternalUrlUseCase = MockOpenExternalUrlUseCase();
      trackingDelegate = MockJobOpeningTrackingDelegate();
    });

    JobOpeningBloc buildBloc() => JobOpeningBloc(
      getJobOpeningUseCase,
      openExternalUrlUseCase,
      trackingDelegate,
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should load the opening by its ID when started',
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningStartedEvent(id: 'job-1')),
      expect: () => [
        const JobOpeningState(id: 'job-1'),
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpening,
        ),
      ],
      verify: (_) {
        verify(() => getJobOpeningUseCase('job-1')).called(1);
        verify(() => trackingDelegate.trackScreenView()).called(1);
      },
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should show the failure when the opening cannot be loaded',
      setUp: () => getJobOpeningUseCase.stubCall(
        const Left(GetJobOpeningNotFoundFailure()),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningStartedEvent(id: 'job-1')),
      expect: () => const [
        JobOpeningState(id: 'job-1'),
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.failed,
          loadFailure: GetJobOpeningNotFoundFailure(),
        ),
      ],
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should reload the same opening when retry is clicked',
      seed: () => const JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.failed,
        loadFailure: GetJobOpeningNetworkFailure(),
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningRetryClickEvent()),
      expect: () => [
        const JobOpeningState(id: 'job-1'),
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpening,
        ),
      ],
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should open the job page on its board when apply is clicked',
      setUp: () => openExternalUrlUseCase.stubCall(const Right(true)),
      seed: () => JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpening,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const ApplyClickEvent()),
      expect: () => const <JobOpeningState>[],
      verify: (_) {
        final openExternalUrlParam =
            verify(() => openExternalUrlUseCase(captureAny())).captured.single
                as OpenExternalUrlParam;
        expect(openExternalUrlParam.uri, jobOpening.url);
        verify(() => trackingDelegate.trackApplyClick('Remotive')).called(1);
      },
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should show the failure when the job page cannot be opened',
      setUp: () => openExternalUrlUseCase.stubCall(
        const Left(OpenExternalUrlUnknownFailure()),
      ),
      seed: () => JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpening,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const ApplyClickEvent()),
      expect: () => [
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpening,
          applyFailure: const OpenExternalUrlUnknownFailure(),
        ),
      ],
    );
  });
}
