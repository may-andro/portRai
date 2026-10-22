import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/_widget.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:portrai/src/widget/page_header_widget.dart';
import 'package:portrai/src/widget/screen_content_widget.dart';

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
          child: ScreenFooterProviderWidget(
            footer: const Text('footer'),
            child: BlocProvider.value(
              value: bloc,
              child: const ContentWidget(),
            ),
          ),
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
      'should render the flags inside the shared scroll view followed by the footer when the state is loaded',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState([testimonialsFlag]));

        await pumpWidget(tester, bloc);

        expect(
          find.descendant(
            of: find.byType(CustomScrollView),
            matching: find.text(testimonialsFlag.name),
          ),
          findsOneWidget,
        );
        expect(find.byType(SliverList), findsOneWidget);
        expect(find.text('footer', skipOffstage: false), findsOneWidget);
        expect(
          tester.getTopLeft(find.text('footer', skipOffstage: false)).dy,
          greaterThan(
            tester.getBottomLeft(find.text(testimonialsFlag.name)).dy,
          ),
        );
        expect(find.byType(FooterWidget), findsNothing);
      },
    );

    testWidgets(
      'should fill the remaining height with the empty search result followed by the footer when no flags match the query',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState([
              testimonialsFlag,
            ], searchQuery: 'missing'),
          );

        await pumpWidget(tester, bloc);

        expect(find.byType(SliverFillRemaining), findsOneWidget);
        expect(find.text('footer', skipOffstage: false), findsOneWidget);
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

      expect(find.byType(SliverGrid), findsOneWidget);
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

    testWidgets('should show no header actions when the flags are loading', (
      tester,
    ) async {
      final bloc = MockFeatureFlagBloc()
        ..stubState(const FeatureFlagLoadingState());

      await pumpWidget(tester, bloc);

      expect(find.byIcon(Icons.grid_view), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets(
      'should dispatch the view mode and reset events when the header actions '
      'are tapped',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState(allFeatureFlags));

        await pumpWidget(tester, bloc);
        await tester.tap(find.byIcon(Icons.grid_view));
        await tester.tap(find.byIcon(Icons.refresh));

        verify(() => bloc.add(const ToggleViewModeEvent())).called(1);
        verify(() => bloc.add(const ResetAllFeatureFlagsEvent())).called(1);
      },
    );

    testWidgets(
      'should show the list icon when the flags are shown in a grid',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(
            const FeatureFlagLoadedState(
              allFeatureFlags,
              viewMode: FeatureFlagViewMode.grid,
            ),
          );

        await pumpWidget(tester, bloc);

        expect(find.byIcon(Icons.view_list), findsOneWidget);
      },
    );

    testWidgets(
      'should show the header actions next to the logo when shown in a wide '
      'desktop window',
      (tester) async {
        tester.view.physicalSize = const Size(1440, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState(allFeatureFlags));

        await pumpWidget(tester, bloc);

        expect(find.byType(PageHeaderWidget), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(PageHeaderWidget),
            matching: find.byIcon(Icons.grid_view),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(PageHeaderWidget),
            matching: find.byIcon(Icons.refresh),
          ),
          findsOneWidget,
        );
      },
      variant: TargetPlatformVariant.only(TargetPlatform.macOS),
    );

    testWidgets('should keep the search header pinned when the flags scroll', (
      tester,
    ) async {
      final bloc = MockFeatureFlagBloc()
        ..stubState(const FeatureFlagLoadedState(allFeatureFlags));
      await pumpWidget(tester, bloc);
      final searchTop = tester.getTopLeft(find.byType(HeaderWidget)).dy;

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -300));
      await tester.pumpAndSettle();

      expect(find.byType(HeaderWidget), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(HeaderWidget)).dy,
        lessThanOrEqualTo(searchTop),
      );
    });
  });
}
