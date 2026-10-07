import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/bloc/_bloc.dart';
import 'package:portrai/src/feature/feature_flag/presentation/screen/feature_flag/feature_flag_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../mock/feature/feature_flag/presentation/screen/feature_flag/bloc/mock_feature_flag_bloc.dart';
import '../../../../../../mock/feature/feature_flag/test_data/feature_flag_test_data.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('FeatureFlagScreen', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    Future<void> pumpScreen(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          navigatorObservers: [routeObserver],
          builder: (_, child) {
            return DSThemeBuilderWidget(
              brightness: Brightness.light,
              designSystem: DesignSystem.beltane,
              child: child!,
            );
          },
          home: const FeatureFlagScreen(),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should resolve the bloc and dispatch load screen visible and loading impression events when built',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadingState());
        appServiceLocator.registerFactory<FeatureFlagBloc>(() => bloc);

        await pumpScreen(tester);

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(const LoadFeatureFlagEvent())).called(1);
        verify(() => bloc.add(const ScreenVisibleEvent())).called(1);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );

    testWidgets(
      'should dispatch app bar events when the loaded actions are tapped',
      (tester) async {
        final bloc = MockFeatureFlagBloc()
          ..stubState(const FeatureFlagLoadedState(allFeatureFlags));
        appServiceLocator.registerFactory<FeatureFlagBloc>(() => bloc);

        await pumpScreen(tester);

        await tester.tap(find.byIcon(Icons.grid_view));
        await tester.pump();
        await tester.tap(find.byIcon(Icons.refresh));
        await tester.pump();

        verify(() => bloc.add(const ToggleViewModeEvent())).called(1);
        verify(() => bloc.add(const ResetAllFeatureFlagsEvent())).called(1);
      },
    );
  });
}
