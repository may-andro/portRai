import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/widget/_widget.dart';

import '../../../../../../../mock/feature/job_opening/domain/entity/job_opening_entity_fixture.dart';
import '../../../../../../../mock/feature/job_opening/presentation/screen/job_opening/bloc/mock_job_opening_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  Future<MockJobOpeningBloc> pumpContent(
    WidgetTester tester,
    JobOpeningState state,
  ) async {
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
    expect(find.text('82% fit'), findsOneWidget);
    expect(find.text('Remotive · Oct 17, 2026'), findsOneWidget);
    expect(find.text('Why it fits'), findsOneWidget);
    expect(find.text('Skills the job also asks for'), findsOneWidget);
    expect(find.text('GraphQL'), findsOneWidget);
  });

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
  });

  testWidgets('should dispatch apply when the apply button is tapped', (
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

    await tester.tap(find.text('Apply on Remotive'));
    await tester.pump();

    verify(() => bloc.add(const ApplyClickEvent())).called(1);
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
}
