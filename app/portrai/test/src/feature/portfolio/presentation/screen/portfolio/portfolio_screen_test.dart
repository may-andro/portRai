import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/_bloc.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/portfolio_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../mock/feature/portfolio/presentation/screen/portfolio/bloc/mock_portfolio_bloc.dart';
import '../../../../../../util/assistant_bloc_scope.dart';
import '../../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUp(resetTrackingImpressions);

  group('PortfolioScreen', () {
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
          home: const AssistantBlocScope(child: PortfolioScreen()),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should resolve the bloc and dispatch load screen visible and loading impression events when built',
      (tester) async {
        final bloc = MockPortfolioBloc()..stubState(const LoadingState());
        appServiceLocator.registerFactory<PortfolioBloc>(() => bloc);

        await pumpScreen(tester);

        expect(find.byType(DSLoadingWidget), findsOneWidget);
        verify(() => bloc.add(const LoadPortfolioEvent())).called(1);
        verify(() => bloc.add(const ScreenVisibleEvent())).called(1);
        verify(() => bloc.add(ViewStateVisibleEvent.loading())).called(1);
      },
    );
  });
}
