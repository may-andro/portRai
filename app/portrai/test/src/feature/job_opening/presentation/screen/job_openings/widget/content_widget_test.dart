import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/widget/_widget.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_openings/bloc/mock_job_openings_bloc.dart';
import '../../../../../../../util/animated_page_test_util.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockJobOpeningsBloc> pumpContent(
    WidgetTester tester,
    JobOpeningsState state,
  ) async {
    setUpAnimatedPage(tester);
    final bloc = MockJobOpeningsBloc()..stubState(state);
    addTearDown(bloc.close);
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => BlocProvider<JobOpeningsBloc>.value(
            value: bloc,
            child: const Scaffold(body: ContentWidget()),
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
    expect(find.text('Remotive · Oct 17, 2026'), findsOneWidget);
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
}
