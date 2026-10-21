import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/widget/_widget.dart';

import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_openings/bloc/mock_job_openings_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockJobOpeningsBloc> pumpContent(
    WidgetTester tester,
    JobOpeningsState state,
  ) async {
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
    await tester.pump();
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
    expect(find.text('82% fit'), findsOneWidget);
    expect(find.text('Acme · Europe'), findsOneWidget);
    expect(find.text('Remotive · Oct 17, 2026'), findsOneWidget);
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
    await tester.pumpAndSettle();

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
    final errorCard = tester.widget<DSErrorCardWidget>(
      find.byType(DSErrorCardWidget),
    );
    errorCard.onRetryClicked!();

    verify(() => bloc.add(const JobOpeningsRetryClickEvent())).called(1);
  });

  testWidgets('should hide the switch when the setting is unknown', (
    tester,
  ) async {
    await pumpContent(
      tester,
      const JobOpeningsState(status: JobOpeningsStatus.loaded),
    );

    expect(find.byType(SwitchListTile), findsNothing);
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

    await tester.tap(find.byType(SwitchListTile));
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

    final switchTile = tester.widget<SwitchListTile>(
      find.byType(SwitchListTile),
    );
    expect(switchTile.onChanged, isNull);
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
}
