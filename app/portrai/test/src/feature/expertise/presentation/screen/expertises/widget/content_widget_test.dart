import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/widget/content_widget.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

import '../../../../../../../mock/feature/expertise/presentation/screen/expertises/bloc/mock_expertises_bloc.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  Future<void> pumpContent(WidgetTester tester, MockExpertisesBloc bloc) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: ScreenFooterProviderWidget(
          footer: const Text('footer'),
          child: BlocProvider<ExpertisesBloc>.value(
            value: bloc,
            child: const ContentWidget(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  group('Expertises ContentWidget', () {
    testWidgets('should render loading and track its impression when loading', (
      tester,
    ) async {
      final bloc = MockExpertisesBloc()..stubState(const LoadingState());

      await pumpContent(tester, bloc);

      expect(find.byType(DSLoadingWidget), findsOneWidget);
      verify(
        () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
      ).called(1);
    });

    testWidgets(
      'should render an error card and track its impression when loading fails',
      (tester) async {
        final bloc = MockExpertisesBloc()
          ..stubState(const ErrorState(failure: ExpertiseNotFoundFailure()));

        await pumpContent(tester, bloc);

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an expertise list and track its impression when loading succeeds',
      (tester) async {
        final bloc = MockExpertisesBloc()
          ..stubState(const LoadedState(expertises: []));

        await pumpContent(tester, bloc);

        expect(find.byType(ExpertiseListWidget), findsOneWidget);
        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should end the shared scroll view with the provided footer when loading succeeds',
      (tester) async {
        final bloc = MockExpertisesBloc()
          ..stubState(const LoadedState(expertises: []));

        await pumpContent(tester, bloc);

        final scrollView = find.byType(CustomScrollView);
        expect(scrollView, findsOneWidget);
        expect(
          find.descendant(
            of: scrollView,
            matching: find.byType(ExpertiseListWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: scrollView,
            matching: find.text('footer', skipOffstage: false),
            skipOffstage: false,
          ),
          findsOneWidget,
        );
        expect(
          tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
          greaterThanOrEqualTo(
            tester.getBottomLeft(find.byType(ExpertiseListWidget)).dy,
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );
  });
}
