import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../../../../../../../mock/feature/cv_export/domain/use_case/mock_is_cv_tailoring_available_use_case.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_get_job_opening_use_case.dart';
import '../../../../../../../mock/feature/job_opening/domain/use_case/mock_is_job_opening_insights_available_use_case.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_opening/tracking/mock_job_opening_tracking_delegate.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_ask_remote_portfolio_question_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_reset_remote_assistant_session_use_case.dart';

void main() {
  const insightsResponse = '''
```json
{"version":"v0.9","createSurface":{"surfaceId":"insights","catalogId":"dev.portrai.assistant"}}
```
```json
{"version":"v0.9","updateComponents":{"surfaceId":"insights","components":[
{"id":"root","component":"DSCard","child":"body"},
{"id":"body","component":"DSText","text":"Lead with Flutter"}]}}
```
''';

  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
    registerFallbackValue(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Portfolio',
        history: const [],
        onDelta: (_) {},
      ),
    );
  });

  group('JobOpeningBloc', () {
    late MockGetJobOpeningUseCase getJobOpeningUseCase;
    late MockOpenExternalUrlUseCase openExternalUrlUseCase;
    late MockIsJobOpeningInsightsAvailableUseCase
    isJobOpeningInsightsAvailableUseCase;
    late MockGetAssistantContextUseCase getAssistantContextUseCase;
    late MockAskRemotePortfolioQuestionUseCase
    askRemotePortfolioQuestionUseCase;
    late MockResetRemoteAssistantSessionUseCase
    resetRemoteAssistantSessionUseCase;
    late MockIsCvTailoringAvailableUseCase isCvTailoringAvailableUseCase;
    late MockJobOpeningTrackingDelegate trackingDelegate;

    final jobOpening = jobOpeningEntityFixture();

    setUp(() {
      getJobOpeningUseCase = MockGetJobOpeningUseCase()
        ..stubCall(Right(jobOpening));
      openExternalUrlUseCase = MockOpenExternalUrlUseCase();
      isJobOpeningInsightsAvailableUseCase =
          MockIsJobOpeningInsightsAvailableUseCase()
            ..stubCall(const Right(false));
      getAssistantContextUseCase = MockGetAssistantContextUseCase();
      when(
        () => getAssistantContextUseCase(),
      ).thenAnswer((_) => const Right('Portfolio'));
      askRemotePortfolioQuestionUseCase =
          MockAskRemotePortfolioQuestionUseCase();
      resetRemoteAssistantSessionUseCase =
          MockResetRemoteAssistantSessionUseCase()..stubCall(const Right(null));
      isCvTailoringAvailableUseCase = MockIsCvTailoringAvailableUseCase()
        ..stubCall(const Right(false));
      trackingDelegate = MockJobOpeningTrackingDelegate();
    });

    JobOpeningBloc buildBloc() => JobOpeningBloc(
      getJobOpeningUseCase,
      openExternalUrlUseCase,
      isJobOpeningInsightsAvailableUseCase,
      getAssistantContextUseCase,
      askRemotePortfolioQuestionUseCase,
      resetRemoteAssistantSessionUseCase,
      isCvTailoringAvailableUseCase,
      trackingDelegate,
    );

    void stubInsights(String response) {
      when(() => askRemotePortfolioQuestionUseCase(any())).thenAnswer((
        invocation,
      ) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta(response);
        return Future.value(const Right(null));
      });
    }

    Future<void> waitFor(
      JobOpeningBloc bloc,
      bool Function(JobOpeningState) predicate,
    ) async {
      if (predicate(bloc.state)) return;
      await bloc.stream
          .firstWhere(predicate)
          .timeout(const Duration(seconds: 3));
    }

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

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should offer insights when they are available',
      setUp: () =>
          isJobOpeningInsightsAvailableUseCase.stubCall(const Right(true)),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningStartedEvent(id: 'job-1')),
      skip: 2,
      expect: () => [
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpening,
          insightsStatus: JobOpeningInsightsStatus.idle,
        ),
      ],
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should offer a tailored CV when tailoring is available',
      setUp: () => isCvTailoringAvailableUseCase.stubCall(const Right(true)),
      build: buildBloc,
      act: (bloc) => bloc.add(const JobOpeningStartedEvent(id: 'job-1')),
      skip: 2,
      expect: () => [
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpening,
          isTailoredCvAvailable: true,
        ),
      ],
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should track the tailored CV click with the job board',
      seed: () => JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpening,
        isTailoredCvAvailable: true,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const TailoredCvClickEvent()),
      expect: () => const <JobOpeningState>[],
      verify: (_) => verify(
        () => trackingDelegate.trackTailoredCvClick('Remotive'),
      ).called(1),
    );

    blocTest<JobOpeningBloc, JobOpeningState>(
      'should ignore the insights click when insights are unavailable',
      seed: () => JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpening,
      ),
      build: buildBloc,
      act: (bloc) => bloc.add(const GenerateInsightsClickEvent()),
      expect: () => const <JobOpeningState>[],
      verify: (_) =>
          verifyNever(() => askRemotePortfolioQuestionUseCase(any())),
    );

    test('should render the generated insights when insights are '
        'clicked', () async {
      stubInsights(insightsResponse);
      final bloc = buildBloc()
        ..emit(
          JobOpeningState(
            id: 'job-1',
            status: JobOpeningStatus.loaded,
            jobOpening: jobOpening,
            insightsStatus: JobOpeningInsightsStatus.idle,
          ),
        );
      addTearDown(bloc.close);

      bloc.add(const GenerateInsightsClickEvent());
      await waitFor(
        bloc,
        (state) => state.insightsStatus == JobOpeningInsightsStatus.ready,
      );

      expect(bloc.state.insightsSurfaceIds, ['insights']);
      expect(bloc.state.insightsController, isNotNull);
      expect(bloc.state.insightsFailure, isNull);
      final params =
          verify(
                () => askRemotePortfolioQuestionUseCase(captureAny()),
              ).captured.single
              as AskRemotePortfolioQuestionParams;
      expect(params.portfolioContext, startsWith('Portfolio'));
      expect(params.portfolioContext, contains('Senior Flutter Developer'));
      expect(params.history, isEmpty);
      verify(
        () => trackingDelegate.trackGenerateInsightsClick('Remotive'),
      ).called(1);
    });

    test('should show the failure when the insights cannot be '
        'generated', () async {
      when(() => askRemotePortfolioQuestionUseCase(any())).thenAnswer(
        (_) => Future.value(const Left(RemoteAssistantQuotaFailure())),
      );
      final bloc = buildBloc()
        ..emit(
          JobOpeningState(
            id: 'job-1',
            status: JobOpeningStatus.loaded,
            jobOpening: jobOpening,
            insightsStatus: JobOpeningInsightsStatus.idle,
          ),
        );
      addTearDown(bloc.close);

      bloc.add(const GenerateInsightsClickEvent());
      await waitFor(
        bloc,
        (state) => state.insightsStatus == JobOpeningInsightsStatus.failed,
      );

      expect(bloc.state.insightsFailure, const RemoteAssistantQuotaFailure());
      expect(bloc.state.insightsController, isNull);
      expect(bloc.state.insightsSurfaceIds, isEmpty);
    });

    test('should fail as incomplete when the answer holds no '
        'insights', () async {
      stubInsights('Only prose, no components.');
      final bloc = buildBloc()
        ..emit(
          JobOpeningState(
            id: 'job-1',
            status: JobOpeningStatus.loaded,
            jobOpening: jobOpening,
            insightsStatus: JobOpeningInsightsStatus.idle,
          ),
        );
      addTearDown(bloc.close);

      bloc.add(const GenerateInsightsClickEvent());
      await waitFor(
        bloc,
        (state) => state.insightsStatus == JobOpeningInsightsStatus.failed,
      );

      expect(
        bloc.state.insightsFailure,
        const RemoteAssistantIncompleteFailure(),
      );
    });

    test('should show the failure when the portfolio cannot be '
        'read', () async {
      when(
        () => getAssistantContextUseCase(),
      ).thenAnswer((_) => const Left(UnknownAssistantFailure()));
      final bloc = buildBloc()
        ..emit(
          JobOpeningState(
            id: 'job-1',
            status: JobOpeningStatus.loaded,
            jobOpening: jobOpening,
            insightsStatus: JobOpeningInsightsStatus.idle,
          ),
        );
      addTearDown(bloc.close);

      bloc.add(const GenerateInsightsClickEvent());
      await waitFor(
        bloc,
        (state) => state.insightsStatus == JobOpeningInsightsStatus.failed,
      );

      expect(bloc.state.insightsFailure, const UnknownAssistantFailure());
      verifyNever(() => askRemotePortfolioQuestionUseCase(any()));
    });

    test('should cancel the request when closed while generating', () async {
      final answer = Completer<Either<RemoteAssistantFailure, void>>();
      when(
        () => askRemotePortfolioQuestionUseCase(any()),
      ).thenAnswer((_) => answer.future);
      final bloc = buildBloc()
        ..emit(
          JobOpeningState(
            id: 'job-1',
            status: JobOpeningStatus.loaded,
            jobOpening: jobOpening,
            insightsStatus: JobOpeningInsightsStatus.idle,
          ),
        );

      bloc.add(const GenerateInsightsClickEvent());
      await waitFor(bloc, (state) => state.insightsController != null);
      await bloc.close();
      answer.complete(const Right(null));

      verify(() => resetRemoteAssistantSessionUseCase()).called(1);
    });
  });
}
