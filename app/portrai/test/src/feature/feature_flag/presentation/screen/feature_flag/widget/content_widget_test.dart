import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/_widget.dart';

import '../../../../../../../mock/feature/feature_flag/presentation/screen/feature_flag/bloc/mock_feature_flag_bloc.dart';
import '../../../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';
import '../../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(testimonialsFlag);
  });

  setUp(resetTrackingImpressions);

  group('ContentWidget', () {
    Future<void> pumpWidget(WidgetTester tester, FeatureFlagBloc bloc) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(value: bloc, child: const ContentWidget()),
        ),
      );
      await tester.pump();
    }

    testWidgets('should render a loading indicator when the state is loading', (
      tester,
    ) async {
      final bloc = MockFeatureFlagBloc()
        ..stubState(const FeatureFlagLoadingState());

      await pumpWidget(tester, bloc);

      expect(find.byType(DSLoadingWidget), findsOneWidget);
    });

    testWidgets(
      'should dispatch loading impression event when the loading content becomes visible',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadingState());

        await pumpWidget(tester, bloc);

        verify(
          () => bloc.add(const ViewStateVisibleEvent('loading_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an error card with the translated failure when the state is error',
      (tester) async {
        const state = FeatureFlagErrorState(FeatureFlagsNotFoundFailure());
        final bloc = MockFeatureFlagBloc()..stubState(state);

        await pumpWidget(tester, bloc);

        expect(find.byType(DSErrorCardWidget), findsOneWidget);
        expect(find.text('No feature flags found'), findsOneWidget);
      },
    );

    testWidgets(
      'should dispatch error impression event when the error content becomes visible',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagErrorState(FeatureFlagsNotFoundFailure()),
          );

        await pumpWidget(tester, bloc);

        verify(
          () => bloc.add(const ViewStateVisibleEvent('error_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render feature flag cards when the state is loaded in list mode',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState([testimonialsFlag, servicesFlag]),
          );

        await pumpWidget(tester, bloc);

        expect(find.text(testimonialsFlag.name), findsOneWidget);
        expect(find.text(servicesFlag.name), findsOneWidget);
        expect(find.text(testimonialsFlag.statusDescription), findsOneWidget);
        expect(find.text(servicesFlag.statusDescription), findsOneWidget);
      },
    );

    testWidgets(
      'should dispatch success impression event when the loaded content becomes visible',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState([testimonialsFlag]));

        await pumpWidget(tester, bloc);

        verify(
          () => bloc.add(const ViewStateVisibleEvent('loaded_content_view')),
        ).called(1);
      },
    );

    testWidgets(
      'should render an empty search result when no flags match the query',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState([
              testimonialsFlag,
            ], searchQuery: 'missing'),
          );

        await pumpWidget(tester, bloc);

        final context = tester.element(find.byType(ContentWidget));
        expect(
          find.text(context.localizations.featureFlagEmptySearchTitle),
          findsOneWidget,
        );
        expect(
          find.text(
            context.localizations.featureFlagEmptySearchMessage('missing'),
          ),
          findsOneWidget,
        );
      },
    );

    testWidgets('should render a grid when the state is loaded in grid mode', (
      tester,
    ) async {
      final bloc = MockFeatureFlagBloc()
        ..stubState(
          const FeatureFlagLoadedState([
            testimonialsFlag,
            servicesFlag,
          ], viewMode: FeatureFlagViewMode.grid),
        );

      await pumpWidget(tester, bloc);

      expect(find.byType(GridView), findsOneWidget);
      expect(find.text(testimonialsFlag.name), findsOneWidget);
      expect(find.text(servicesFlag.name), findsOneWidget);
    });

    testWidgets(
      'should dispatch ToggleFeatureFlagEvent when a list item is tapped',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState([testimonialsFlag]));

        await pumpWidget(tester, bloc);
        await tester.tap(find.text(testimonialsFlag.name));
        await tester.pump();

        verify(
          () => bloc.add(const ToggleFeatureFlagEvent(testimonialsFlag)),
        ).called(1);
      },
    );
  });
}
