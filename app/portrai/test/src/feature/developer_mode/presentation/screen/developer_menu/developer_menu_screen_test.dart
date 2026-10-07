import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/developer_menu_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../mock/feature/developer_mode/presentation/screen/developer_menu/bloc/mock_developer_menu_bloc.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('DeveloperMenuScreen', () {
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
          home: const DeveloperMenuScreen(),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should resolve the bloc and dispatch load screen visible and loading impression events when built',
      (tester) async {
        final bloc = MockDeveloperMenuBloc()
          ..stubState(const DeveloperMenuLoadingState());
        appServiceLocator.registerFactory<DeveloperMenuBloc>(() => bloc);

        await pumpScreen(tester);

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(const LoadDeveloperMenuEvent())).called(1);
        verify(() => bloc.add(const ScreenVisibleEvent())).called(1);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );
  });
}
