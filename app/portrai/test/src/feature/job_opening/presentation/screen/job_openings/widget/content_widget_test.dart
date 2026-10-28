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
import '../../../../../../../util/date_test_util.dart';
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
    expect(
      tester
          .widget<JobFitScoreWidget>(find.byType(JobFitScoreWidget))
          .isAnimated,
      isFalse,
    );
    expect(find.byIcon(Icons.arrow_outward_rounded), findsNothing);
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

  testWidgets('should leave the skills out of the compact card when loaded', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(matchedSkills: ['Riverpod', 'Bloc']),
        ],
      ),
    );

    expect(find.byType(DSTagWidget), findsNothing);
    expect(find.text('Riverpod'), findsNothing);
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

    verify(
      () => bloc.add(
        const JobOpeningClickEvent(
          label: 'job_opening_card',
          jobOpeningId: 'job-7',
        ),
      ),
    ).called(1);
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

  testWidgets('should show the Lottie loader at the app-wide size while '
      'loading', (tester) async {
    await pumpContent(tester, const JobOpeningsState());

    final loader = tester.widget<DSLoadingWidget>(find.byType(DSLoadingWidget));
    expect(loader.style, DSLoadingStyle.lottie);
    // A tenth of the shortest side of the 1440 x 2400 test window.
    expect(loader.size, 144);
  });

  testWidgets('should show sign out in the header while the matches load', (
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
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(
            id: '1',
            title: 'First',
            publishedAt: calendarDaysAgo(0),
          ),
          jobOpeningEntityFixture(
            id: '2',
            title: 'Second',
            publishedAt: calendarDaysAgo(1),
          ),
          jobOpeningEntityFixture(
            id: '3',
            title: 'Third',
            publishedAt: calendarDaysAgo(12),
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

    expect(find.textContaining('Contract · Posted'), findsOneWidget);
    expect(find.textContaining('Freelance · Posted'), findsOneWidget);
  });

  testWidgets('should show the platform logo behind Flutter, Android and iOS '
      'openings', (tester) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1'),
          jobOpeningEntityFixture(
            id: '2',
            title: 'Android Engineer',
            tags: [],
            matchedSkills: ['Kotlin'],
          ),
          jobOpeningEntityFixture(
            id: '3',
            title: 'iOS Engineer',
            tags: [],
            matchedSkills: ['Swift'],
          ),
          jobOpeningEntityFixture(
            id: '4',
            title: 'Backend Engineer',
            tags: [],
            matchedSkills: ['Go'],
          ),
        ],
      ),
    );

    bool isBackgroundLogo(Widget widget) => switch (widget) {
      FlutterLogo(:final size) => size == 120,
      Icon(:final size) => size == 120,
      _ => false,
    };
    final backgroundLogos = tester
        .widgetList(find.byWidgetPredicate(isBackgroundLogo))
        .map((widget) => widget is Icon ? widget.icon : widget.runtimeType);
    expect(backgroundLogos, [
      FlutterLogo,
      Icons.android_rounded,
      Icons.apple_rounded,
    ]);
  });

  testWidgets('should dispatch the search when text is typed', (tester) async {
    final bloc = await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
      ),
    );

    await tester.enterText(find.byType(TextFormField), 'acme');
    await tester.pump();

    verify(
      () => bloc.add(const JobOpeningsSearchChangedEvent('acme')),
    ).called(1);
  });

  testWidgets('should offer only the filters that match an opening', (
    tester,
  ) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', score: 85),
          jobOpeningEntityFixture(id: '2', score: 72),
        ],
      ),
    );

    final chipLabels = find.descendant(
      of: find.byType(FilterChip),
      matching: find.byType(DSTextWidget),
    );
    expect(
      tester.widgetList<DSTextWidget>(chipLabels).map((text) => text.data),
      ['Flutter', '2', 'Strong fit', '1'],
    );
  });

  testWidgets('should dispatch the filter when its chip is tapped', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
      ),
    );

    await tester.tap(find.widgetWithText(FilterChip, 'Flutter'));
    await tester.pump();

    verify(
      () => bloc.add(
        const JobOpeningsFilterClickEvent(JobOpeningsFilter.flutter),
      ),
    ).called(1);
  });

  testWidgets('should show only the matching openings and their count when '
      'narrowed', (tester) async {
    await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [
          jobOpeningEntityFixture(id: '1', title: 'First'),
          jobOpeningEntityFixture(id: '2', title: 'Second', company: 'Globex'),
        ],
        searchQuery: 'globex',
      ),
    );

    expect(find.text('First'), findsNothing);
    expect(find.text('Second'), findsOneWidget);
    expect(find.text('Showing 1 of 2'), findsOneWidget);
  });

  testWidgets('should offer to clear the filters when nothing matches', (
    tester,
  ) async {
    final bloc = await pumpContent(
      tester,
      JobOpeningsState(
        status: JobOpeningsStatus.loaded,
        jobOpenings: [jobOpeningEntityFixture()],
        filters: const {JobOpeningsFilter.android},
      ),
    );

    expect(find.text('No jobs match your search and filters.'), findsOneWidget);
    final clearButton = find.widgetWithText(DSButtonWidget, 'Clear filters');
    await tester.ensureVisible(clearButton.last);
    await tester.tap(clearButton.last);
    await tester.pump();

    verify(() => bloc.add(const JobOpeningsClearFiltersClickEvent())).called(1);
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
      // The search field has a scrollable of its own.
      scrollable: find.byType(Scrollable).first,
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
