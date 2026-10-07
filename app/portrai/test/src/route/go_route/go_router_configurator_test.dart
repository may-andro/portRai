import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_module_route_controller.dart';

void main() {
  group('GoRouterConfigurator', () {
    testWidgets(
      'should build nested module routes when the router navigates to them',
      (tester) async {
        final controller = MockModuleRouteController();
        final configurator = GoRouterConfigurator(controller, const []);
        when(() => controller.allRoutes).thenReturn([
          ModuleRoute(
            name: 'home',
            path: '/',
            builder: (_, _, _) => const Scaffold(body: Text('Home')),
            children: [
              ModuleRoute(
                name: 'details',
                path: 'details',
                builder: (_, _, _) => const Scaffold(body: Text('Details')),
              ),
            ],
          ),
        ]);
        final router = configurator.router;

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) {
              return DSThemeBuilderWidget(
                brightness: Brightness.light,
                designSystem: DesignSystem.beltane,
                child: child!,
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);

        router.go('/details');
        await tester.pumpAndSettle();

        expect(find.text('Details'), findsOneWidget);
      },
    );

    testWidgets(
      'should build the route not found screen when navigation fails',
      (tester) async {
        final controller = MockModuleRouteController();
        final configurator = GoRouterConfigurator(controller, const []);
        when(() => controller.allRoutes).thenReturn([
          ModuleRoute(
            name: 'home',
            path: '/',
            builder: (_, _, _) => const Scaffold(body: Text('Home')),
          ),
        ]);
        final router = configurator.router;

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) {
              return DSThemeBuilderWidget(
                brightness: Brightness.light,
                designSystem: DesignSystem.beltane,
                child: child!,
              );
            },
          ),
        );
        await tester.pumpAndSettle();

        router.go('/missing');
        await tester.pumpAndSettle();

        expect(find.byType(RouteNotFoundScreen), findsOneWidget);
      },
    );
  });
}
