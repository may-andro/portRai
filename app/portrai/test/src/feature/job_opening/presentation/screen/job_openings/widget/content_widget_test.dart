import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/widget/_widget.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_openings/bloc/mock_job_openings_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<void> pumpBloc(WidgetTester tester, MockJobOpeningsBloc bloc) async {
    setUpAnimatedPage(tester);
    addTearDown(bloc.close);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => ScreenFooterProviderWidget(
            footer: const Text('footer'),
            child: BlocProvider<JobOpeningsBloc>.value(
              value: bloc,
              child: const Scaffold(body: ContentWidget()),
            ),
          ),
        ),
        GoRoute(
          name: 'job_opening',
          path: '/job-openings/:id',
          builder: (_, state) => Text('Opening ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await pumpAnimations(tester);
  }

  Future<MockJobOpeningsBloc> pumpContent(
    WidgetTester tester,
    JobOpeningsState state,
  ) async {
    final bloc = MockJobOpeningsBloc()..stubState(state);
    await pumpBloc(tester, bloc);
    return bloc;
  }

  testWidgets('should show each opening with its fit and source when '
      'loaded', (tester) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
      ),
    );

    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is JobFitScoreWidget && widget.score == 82,
      ),
      findsOneWidget,
    );
    expect(find.text('Acme · Europe'), findsOneWidget);
    expect(find.text('Remotive'), findsOneWidget);
  });

  testWidgets('should summarize the matches in the hero when loaded', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', score: 74),
          jobOpeningEntityFixture(id: '2', score: 91),
        ],
      ),
    );

    expect(find.text('2 matches'), findsOneWidget);
    expect(find.text('Your matches'), findsOneWidget);
    expect(find.text('Best fit 91%'), findsOneWidget);
    expect(find.text('Updated Oct 19, 2026'), findsOneWidget);
  });

  testWidgets('should show at most four skills and the number of the rest', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(
            matchedSkills: ['A1', 'B2', 'C3', 'D4', 'E5', 'F6'],
          ),
        ],
      ),
    );

    expect(find.text('D4'), findsOneWidget);
    expect(find.text('E5'), findsNothing);
    expect(find.text('+2'), findsOneWidget);
  });

  testWidgets('should open the opening and track the click when it is '
      'tapped', (tester) async {
    final bloc = await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture(id: 'job-7')],
      ),
    );

    await tester.tap(find.text('Senior Flutter Developer'));
    await pumpAnimations(tester);

    verify(() => bloc.add(const JobOpeningClickEvent())).called(1);
    expect(find.text('Opening job-7'), findsOneWidget);
  });

  testWidgets('should explain the empty list when there are no openings', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const JobOpeningsState(status: JobOpeningsStatus.loaded),
    );

    expect(
      find.text('No matching jobs right now. New ones are found every Monday.'),
      findsOneWidget,
    );
  });

  testWidgets('should show the failure and retry when loading failed', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      const JobOpeningsState(
        status: JobOpeningsStatus.failed,
        loadFailure: GetJobOpeningsPermissionDeniedFailure(),
      ),
    );

    expect(
      find.text("You don't have access to these job openings"),
      findsOneWidget,
    );
    tester
        .widget<DSErrorCardWidget>(find.byType(DSErrorCardWidget))
        .onRetryClicked!();

    verify(() => bloc.add(const JobOpeningsRetryClickEvent())).called(1);
  });

  testWidgets('should hide the switch when the setting is unknown', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const JobOpeningsState(status: JobOpeningsStatus.loaded),
    );

    expect(find.byType(Switch), findsNothing);
    expect(find.text('Sign out'), findsOneWidget);
  });

  testWidgets('should dispatch the new value when the switch is toggled', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      const JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        isJobSearchEnabled: true,
      ),
    );

    await tester.tap(find.byType(Switch));
    await tester.pump();

    verify(
      () => bloc.add(const JobSearchToggleClickEvent(isEnabled: false)),
    ).called(1);
  });

  testWidgets('should disable the switch while the setting is saving', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        isJobSearchEnabled: true,
        isUpdatingJobSearch: true,
      ),
    );

    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });

  testWidgets('should dispatch sign out when sign out is tapped', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      const JobOpeningsState(status: JobOpeningsStatus.loaded),
    );

    await tester.tap(find.text('Sign out'));
    await tester.pump();

    verify(() => bloc.add(const SignOutClickEvent())).called(1);
  });

  testWidgets('should lay the cards out in one column on a phone', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', title: 'First'),
          jobOpeningEntityFixture(id: '2', title: 'Second'),
        ],
      ),
    );
    setUpAnimatedPage(tester, size: const Size(390, 2400));
    await pumpAnimations(tester);

    final first = tester.getTopLeft(find.text('First'));
    final second = tester.getTopLeft(find.text('Second'));
    expect(first.dx, second.dx);
    expect(second.dy, greaterThan(first.dy));
  });

  testWidgets('should lay the cards out side by side on a desktop', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', title: 'First'),
          jobOpeningEntityFixture(id: '2', title: 'Second'),
        ],
      ),
    );

    final first = tester.getTopLeft(find.text('First'));
    final second = tester.getTopLeft(find.text('Second'));
    expect(first.dy, second.dy);
    expect(second.dx, greaterThan(first.dx));
  });

  for (final (isEnabled, status) in [
    (true, 'Active · Next search on Monday'),
    (false, 'Paused · No new searches'),
  ]) {
    testWidgets('should show "$status" when job search is '
        '${isEnabled ? 'on' : 'off'}', (tester) async {
      await pumpContent(
        tester,
        JobOpeningsState(
          status: JobOpeningsStatus.loaded,
          isJobSearchEnabled: isEnabled,
        ),
      );

      expect(find.text(status), findsOneWidget);
      expect(tester.widget<Switch>(find.byType(Switch)).value, isEnabled);
    });
  }

  testWidgets('should show the Lottie loader at the app-wide size while '
      'loading', (tester) async {
    await pumpContent(tester, const JobOpeningsState());

    final loader = tester.widget<DSLoadingWidget>(find.byType(DSLoadingWidget));
    expect(loader.style, DSLoadingStyle.lottie);
    // A tenth of the shortest side of the 1440 x 2400 test window.
    expect(loader.size, 144);
  });

  testWidgets('should show the job search section while the matches load', (
    tester,
  ) async {
    await pumpContent(tester, const JobOpeningsState());

    expect(find.byType(DSLoadingWidget), findsOneWidget);
    expect(find.text('Sign out'), findsOneWidget);
    expect(find.byType(JobFitScoreWidget), findsNothing);
  });

  testWidgets('should retry when retry is tapped on the error', (tester) async {
    final bloc = await pumpContent(
      tester,
      const JobOpeningsState(status: JobOpeningsStatus.failed),
    );

    final errorCard = find.byType(DSErrorCardWidget);
    expect(errorCard, findsOneWidget);
    await tester.ensureVisible(errorCard);
    await tester.tap(
      find.descendant(of: errorCard, matching: find.byType(DSButtonWidget)),
    );
    await tester.pump();

    verify(() => bloc.add(const JobOpeningsRetryClickEvent())).called(1);
  });

  testWidgets('should show how long ago each opening was posted', (
    tester,
  ) async {
    final now = DateTime.now();
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', title: 'First', publishedAt: now),
          jobOpeningEntityFixture(
            id: '2',
            title: 'Second',
            publishedAt: now.subtract(const Duration(days: 1)),
          ),
          jobOpeningEntityFixture(
            id: '3',
            title: 'Third',
            publishedAt: now.subtract(const Duration(days: 12)),
          ),
        ],
      ),
    );

    expect(find.text('Posted today'), findsOneWidget);
    expect(find.text('Posted yesterday'), findsOneWidget);
    expect(find.text('Posted 12 days ago'), findsOneWidget);
  });

  testWidgets('should highlight contract and freelance openings', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(
            id: '1',
            title: 'Android Engineer (Contract)',
          ),
          jobOpeningEntityFixture(
            id: '2',
            title: 'Flutter Developer',
            jobTypes: ['freelance'],
          ),
          jobOpeningEntityFixture(id: '3'),
        ],
      ),
    );

    expect(find.text('Contract'), findsOneWidget);
    expect(find.text('Freelance'), findsOneWidget);
  });

  testWidgets('should build only the cards in view when there are many '
      'openings', (tester) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          for (var index = 0; index < 60; index++)
            jobOpeningEntityFixture(id: '$index', title: 'Opening $index'),
        ],
      ),
    );

    expect(find.text('Opening 0'), findsOneWidget);
    expect(find.text('Opening 59'), findsNothing);
  });

  testWidgets('should not replay the entrance when scrolling back up', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          for (var index = 0; index < 60; index++)
            jobOpeningEntityFixture(id: '$index', title: 'Opening $index'),
        ],
      ),
    );
    final scrollable = find.byType(Scrollable).first;
    await tester.drag(scrollable, const Offset(0, -20000));
    await pumpAnimations(tester);
    expect(find.text('Opening 0'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('Opening 0'),
      -500,
      scrollable: scrollable,
    );

    final fade = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('Opening 0'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(fade.opacity.value, 1);
    await pumpAnimations(tester);
  });

  testWidgets('should end the shared scroll view with the screen footer when '
      'loaded', (tester) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
      ),
    );

    final scrollView = find.descendant(
      of: find.byType(ScreenContentWidget<JobOpeningsBloc, JobOpeningsState>),
      matching: find.byType(CustomScrollView),
    );
    expect(scrollView, findsOneWidget);
    expect(
      find.descendant(
        of: scrollView,
        matching: find.text('Senior Flutter Developer'),
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(
      find.text('footer', skipOffstage: false),
      200,
    );
    expect(
      tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
      greaterThan(
        tester.getBottomLeft(find.text('Senior Flutter Developer')).dy,
      ),
    );
    expect(find.byType(FooterWidget), findsNothing);
  });

  testWidgets('should keep the scroll view and update the matches when they '
      'load', (tester) async {
    final states = StreamController<JobOpeningsState>();
    addTearDown(states.close);
    final bloc = MockJobOpeningsBloc()
      ..stubStates(states.stream, initialState: const JobOpeningsState());
    await pumpBloc(tester, bloc);
    final scrollViewWhileLoading = tester.widget<CustomScrollView>(
      find.byType(CustomScrollView),
    );

    states.add(
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
      ),
    );
    await pumpAnimations(tester);

    expect(
      tester.widget<CustomScrollView>(find.byType(CustomScrollView)),
      same(scrollViewWhileLoading),
    );
    expect(find.text('Senior Flutter Developer'), findsOneWidget);
    expect(find.byType(DSLoadingWidget), findsNothing);
  });
}
