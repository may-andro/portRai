import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experience/widget/content_widget.dart';

import '../../../../../../../mock/feature/experience/presentation/screen/experience/bloc/mock_experience_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Experience ContentWidget', () {
    testWidgets(
      'should render a loading indicator and track its impression when loading',
      (tester) async {
        final bloc = MockExperienceBloc()..stubState(const LoadingState());

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ExperienceBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockExperienceBloc()
          ..stubState(const ErrorState(failure: ExperienceNotFoundFailure()));

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: BlocProvider<ExperienceBloc>.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(() => bloc.add(ViewStateVisibleEvent.error())).called(1);
      },
    );

    for (final entry in const {
      'mobile': Size(390, 844),
      'narrow tablet': Size(600, 1000),
      'tablet': Size(820, 1180),
      'desktop': Size(1440, 900),
    }.entries) {
      testWidgets(
        'should render the experience details without errors when on ${entry.key}',
        (tester) async {
          tester.view.physicalSize = entry.value;
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final bloc = MockExperienceBloc()
            ..stubState(
              LoadedState(
                experience: ExperienceEntity(
                  company: 'Acme',
                  position: 'Lead Engineer',
                  location: 'Madrid',
                  startDate: DateTime(2020),
                  endDate: null,
                  current: true,
                  employmentType: 'Full-time',
                  description: 'Short description',
                  longDescription: 'Long description',
                  responsibilities: const ['Lead the team'],
                  achievements: const ['Shipped it'],
                  technologies: const ['Flutter', 'Dart'],
                  companyLogo: '',
                  url: 'https://acme.com',
                  id: 'acme',
                ),
              ),
            );

          await tester.pumpWidget(
            TestWidgetWrapper(
              child: BlocProvider<ExperienceBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          );
          await tester.pump(const Duration(seconds: 3));

          expect(find.text('Lead Engineer'), findsOneWidget);
          expect(find.text('Overview'), findsWidgets);
          expect(tester.takeException(), isNull);
        },
      );
    }
  });
}
