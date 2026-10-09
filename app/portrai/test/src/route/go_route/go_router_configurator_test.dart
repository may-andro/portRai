import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/route/route.dart';

import '../../../mock/utility/mock_module_route_controller.dart';

void main() {
  group('GoRouterConfigurator', () {
    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets(
        'should use ${kIsWeb ? 'fade transitions' : 'adaptive pages'} when navigating on $platform',
        (tester) async {
          final controller = MockModuleRouteController();
          when(() => controller.allRoutes).thenReturn([
            ModuleRoute(
              name: 'home',
              path: '/',
              builder: (_, _, _) => const Scaffold(body: Text('Home')),
            ),
            ModuleRoute(
              name: 'details',
              path: '/details',
              builder: (_, _, _) => const Scaffold(body: Text('Details')),
            ),
          ]);
          final router = GoRouterConfigurator(controller, const []).router;
          addTearDown(router.dispose);

          await tester.pumpWidget(
            MaterialApp.router(
              routerConfig: router,
              theme: ThemeData(platform: platform),
            ),
          );
          await tester.pumpAndSettle();
          unawaited(router.pushNamed<void>('details'));
          await tester.pumpAndSettle();

          final context = tester.element(find.text('Details'));
          final route = ModalRoute.of(context)!;
          if (kIsWeb) {
            expect(route.settings, isA<CustomTransitionPage<dynamic>>());
          } else {
            expect(route.settings, isA<MaterialPage<dynamic>>());
          }
          expect(router.canPop(), isTrue);

          if (!kIsWeb && platform == TargetPlatform.iOS) {
            await tester.dragFrom(const Offset(1, 300), const Offset(600, 0));
          } else {
            router.pop();
          }
          await tester.pumpAndSettle();

          expect(find.text('Home'), findsOneWidget);
          expect(find.text('Details'), findsNothing);
          expect(router.canPop(), isFalse);
        },
      );
    }

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
