import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/widget/app_bar_widget.dart';

import '../../../../../../../mock/feature/feature_flag/presentation/screen/feature_flag/bloc/mock_feature_flag_bloc.dart';
import '../../../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('AppBarWidget', () {
    Future<void> pumpWidget(WidgetTester tester, FeatureFlagBloc bloc) {
      return tester.pumpWidget(
        TestWidgetWrapper(
          child: BlocProvider.value(
            value: bloc,
            child: const AppBarWidget(height: 56),
          ),
        ),
      );
    }

    testWidgets('should show no actions when the flags are not loaded', (
      tester,
    ) async {
      final bloc = MockFeatureFlagBloc()
        ..stubState(const FeatureFlagLoadingState());

      await pumpWidget(tester, bloc);

      expect(find.byIcon(Icons.grid_view), findsNothing);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets(
      'should dispatch the view mode and reset events when the loaded actions are tapped',
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
  });
}
