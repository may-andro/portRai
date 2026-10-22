import 'dart:async';

import 'package:core/core.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/widget/_widget.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_opening/bloc/mock_job_opening_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockJobOpeningBloc> pumpContent(
    WidgetTester tester,
    JobOpeningState state,
  ) async {
    setUpAnimatedPage(tester);
    final bloc = MockJobOpeningBloc()..stubState(state);
    addTearDown(bloc.close);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider<JobOpeningBloc>.value(
          value: bloc,
          child: const ContentWidget(),
        ),
      ),
    );
    await pumpAnimations(tester);
    return bloc;
  }

  testWidgets('should show the fit, the attribution and the reasons when '
      'loaded', (tester) async {
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(),
      ),
    );

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is JobFitScoreWidget && widget.score == 82,
      ),
      findsOneWidget,
    );
    expect(find.text('Strong fit'), findsOneWidget);
    expect(find.text('Remotive'), findsOneWidget);
    expect(find.text('Oct 17, 2026'), findsOneWidget);
    expect(find.text('Full time'), findsOneWidget);
    expect(find.text('Why it fits'), findsOneWidget);
    expect(find.text('The core stack is Flutter.'), findsOneWidget);
    expect(find.text('Skills the job also asks for'), findsOneWidget);
    expect(find.text('GraphQL'), findsOneWidget);
  });

  for (final (score, label) in [
    (85, 'Strong fit'),
    (72, 'Good fit'),
    (61, 'Possible fit'),
  ]) {
    testWidgets('should label a score of $score as $label', (tester) async {
      await pumpContent(
        tester,
        JobOpeningState(
          id: 'job-1',
          status: JobOpeningStatus.loaded,
          jobOpening: jobOpeningEntityFixture(score: score),
        ),
      );

      expect(find.text(label), findsOneWidget);
    });
  }

  testWidgets('should hide empty sections when the opening has no reasons '
      'or missing skills', (tester) async {
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(reasons: [], missingSkills: []),
      ),
    );

    expect(find.text('Why it fits'), findsNothing);
    expect(find.text('Skills the job also asks for'), findsNothing);
    expect(find.text('Your matching skills'), findsOneWidget);
  });

  testWidgets('should dispatch apply from the hero and the closing section', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(),
      ),
    );

    final applyButtons = find.text('Apply on Remotive');
    expect(applyButtons, findsNWidgets(2));
    await tester.tap(applyButtons.first);
    await tester.ensureVisible(applyButtons.last);
    await tester.pump();
    await tester.tap(applyButtons.last);
    await tester.pump();

    verify(() => bloc.add(const ApplyClickEvent())).called(2);
  });

  testWidgets('should explain a missing opening and retry when loading '
      'failed', (tester) async {
    final bloc = await pumpContent(
      tester,
      const JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.failed,
        loadFailure: GetJobOpeningNotFoundFailure(),
      ),
    );

    expect(
      find.text('This job opening is no longer available'),
      findsOneWidget,
    );
    tester
        .widget<DSErrorCardWidget>(find.byType(DSErrorCardWidget))
        .onRetryClicked!();

    verify(() => bloc.add(const JobOpeningRetryClickEvent())).called(1);
  });

  testWidgets('should fit long skill names without overflowing on a phone', (
    tester,
  ) async {
    const longSkill = 'Code Generation (build_runner, json_serializable)';
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(
          matchedSkills: [
            longSkill,
            'Monorepo (Melos / Workspaces)',
            for (var index = 0; index < 20; index++) 'Skill $index',
          ],
        ),
      ),
    );
    setUpAnimatedPage(tester, size: const Size(375, 4000));
    await pumpAnimations(tester);

    expect(tester.takeException(), isNull);
    expect(find.text(longSkill), findsOneWidget);
    expect(find.text('22'), findsOneWidget);
  });

  testWidgets('should show the Lottie loader at the app-wide size while '
      'loading', (tester) async {
    await pumpContent(tester, const JobOpeningState(id: 'job-1'));

    final loader = tester.widget<DSLoadingWidget>(find.byType(DSLoadingWidget));
    expect(loader.style, DSLoadingStyle.lottie);
    // A tenth of the shortest side of the 1440 x 2400 test window.
    expect(loader.size, 144);
  });

  testWidgets('should show how long ago the opening was posted next to its '
      'date', (tester) async {
    final posted = DateTime.now().subtract(const Duration(days: 3));
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(publishedAt: posted),
      ),
    );

    expect(find.text('Posted 3 days ago'), findsOneWidget);
    expect(find.text(DateFormat.yMMMd('en').format(posted)), findsOneWidget);
  });

  JobOpeningState insightsState(
    JobOpeningInsightsStatus insightsStatus, {
    Failure? insightsFailure,
  }) => JobOpeningState(
    id: 'job-1',
    status: JobOpeningStatus.loaded,
    jobOpening: jobOpeningEntityFixture(),
    insightsStatus: insightsStatus,
    insightsFailure: insightsFailure,
  );

  testWidgets('should hide the insights section when insights are '
      'unavailable', (tester) async {
    await pumpContent(
      tester,
      insightsState(JobOpeningInsightsStatus.unavailable),
    );

    expect(find.text('Prepare for this role'), findsNothing);
    expect(find.text('Get insights'), findsNothing);
  });

  testWidgets('should dispatch the insights request when get insights is '
      'tapped', (tester) async {
    final bloc = await pumpContent(
      tester,
      insightsState(JobOpeningInsightsStatus.idle),
    );

    expect(find.text('Prepare for this role'), findsOneWidget);
    expect(find.text('Get tailored insights'), findsOneWidget);
    final button = find.text('Get insights');
    await tester.ensureVisible(button);
    await tester.tap(button);
    await tester.pump();

    verify(() => bloc.add(const GenerateInsightsClickEvent())).called(1);
  });

  testWidgets('should show progress instead of the button while '
      'generating', (tester) async {
    await pumpContent(
      tester,
      insightsState(JobOpeningInsightsStatus.generating),
    );

    expect(find.text('Preparing your insights…'), findsOneWidget);
    expect(find.text('Get insights'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is DSLoadingWidget && widget.style == DSLoadingStyle.lottie,
      ),
      findsOneWidget,
    );
  });

  testWidgets('should offer to generate again once ready', (tester) async {
    await pumpContent(tester, insightsState(JobOpeningInsightsStatus.ready));

    expect(find.text('Generate again'), findsOneWidget);
  });

  testWidgets('should explain the failure and retry when insights '
      'failed', (tester) async {
    final bloc = await pumpContent(
      tester,
      insightsState(
        JobOpeningInsightsStatus.failed,
        insightsFailure: const RemoteAssistantQuotaFailure(),
      ),
    );

    final errorCard = find.byType(DSErrorCardWidget);
    expect(errorCard, findsOneWidget);
    await tester.ensureVisible(errorCard);
    await tester.tap(
      find.descendant(of: errorCard, matching: find.byType(DSButtonWidget)),
    );
    await tester.pump();

    verify(() => bloc.add(const GenerateInsightsClickEvent())).called(1);
  });

  testWidgets('should offer a tailored CV next to apply when '
      'available', (tester) async {
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(),
        isTailoredCvAvailable: true,
      ),
    );

    expect(find.text('Tailored CV'), findsOneWidget);
  });

  testWidgets('should hide the tailored CV when unavailable', (tester) async {
    await pumpContent(
      tester,
      JobOpeningState(
        id: 'job-1',
        status: JobOpeningStatus.loaded,
        jobOpening: jobOpeningEntityFixture(),
      ),
    );

    expect(find.text('Tailored CV'), findsNothing);
  });

  group('rebuilds', () {
    final loadedState = JobOpeningState(
      id: 'job-1',
      status: JobOpeningStatus.loaded,
      jobOpening: jobOpeningEntityFixture(),
      insightsStatus: JobOpeningInsightsStatus.idle,
    );

    Future<StreamController<JobOpeningState>> pumpStates(
      WidgetTester tester,
    ) async {
      setUpAnimatedPage(tester);
      final states = StreamController<JobOpeningState>();
      addTearDown(states.close);
      final bloc = MockJobOpeningBloc()
        ..stubStates(states.stream, initialState: loadedState);
      addTearDown(bloc.close);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<JobOpeningBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await pumpAnimations(tester);
      return states;
    }

    CustomScrollView scrollView(WidgetTester tester) =>
        tester.widget<CustomScrollView>(find.byType(CustomScrollView));

    testWidgets('should not rebuild the page when only the insights '
        'progress changes', (tester) async {
      final states = await pumpStates(tester);
      final pageBeforeInsights = scrollView(tester);

      states.add(
        loadedState.copyWith(
          insightsStatus: JobOpeningInsightsStatus.generating,
        ),
      );
      await tester.pump();
      states.add(
        loadedState.copyWith(
          insightsStatus: JobOpeningInsightsStatus.generating,
          insightsSurfaceIds: const ['surface-1'],
        ),
      );
      await tester.pump();

      expect(scrollView(tester), same(pageBeforeInsights));
      expect(find.text('Preparing your insights…'), findsOneWidget);
    });

    testWidgets('should rebuild the page when the tailored CV becomes '
        'available', (tester) async {
      final states = await pumpStates(tester);
      final pageBeforeTailoredCv = scrollView(tester);

      states.add(loadedState.copyWith(isTailoredCvAvailable: true));
      await tester.pump();

      expect(scrollView(tester), isNot(same(pageBeforeTailoredCv)));
      expect(find.text('Tailored CV'), findsOneWidget);
    });
  });
}
