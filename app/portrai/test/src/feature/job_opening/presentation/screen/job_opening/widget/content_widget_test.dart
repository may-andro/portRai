import 'dart:ui';

import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/domain/_domain.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/widget/_widget.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

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
}
