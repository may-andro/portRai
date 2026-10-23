import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/bloc/_bloc.dart';
import 'package:portrai/src/feature/experience/presentation/screen/experiences/widget/content_widget.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/experience_list.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/experience/presentation/screen/experiences/bloc/mock_experiences_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('Experiences ContentWidget', () {
    testWidgets('should render loading and track its impression when loading', (
      tester,
    ) async {
      const state = LoadingState();
      final bloc = MockExperiencesBloc()..stubState(state);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ExperiencesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(
        () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
      ).called(1);
    });

    testWidgets('should render an error card when loading fails', (
      tester,
    ) async {
      const state = ErrorState(failure: ExperiencesNotFoundFailure());
      final bloc = MockExperiencesBloc()..stubState(state);

      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider<ExperiencesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(DSErrorCardWidget), findsOneWidget);
    });

    testWidgets(
      'should render an experience list in the screen scroll view followed by the footer when loading succeeds',
      (tester) async {
        const state = LoadedState(experiences: []);
        final bloc = MockExperiencesBloc()..stubState(state);

        await tester.pumpWidget(
          TestWidgetWrapper(
            child: ScreenFooterProviderWidget(
              footer: const Text('footer'),
              child: BlocProvider<ExperiencesBloc>.value(
                value: bloc,
                child: const ContentWidget(),
              ),
            ),
          ),
        );
        await tester.pump();

        final scrollView = find.ancestor(
          of: find.byType(ExperienceListWidget),
          matching: find.byType(CustomScrollView),
        );
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(
            of: find.byWidget(
              tester.widget<CustomScrollView>(scrollView).slivers.last,
              skipOffstage: false,
            ),
            matching: find.text('footer', skipOffstage: false),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(find.byType(FooterWidget), findsNothing);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );
  });
}
