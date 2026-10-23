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
    testWidgets(
      'should restart navigation with fresh screens when the app rebuilds with a new router',
      (tester) async {
        var homeInitCount = 0;
        final controller = MockModuleRouteController();
        when(() => controller.redirects).thenReturn(const []);
        when(() => controller.allRoutes).thenReturn([
          ModuleRoute(
            name: 'home',
            path: '/',
            builder: (_, _, _) {
              return _InitCounterWidget(
                label: 'Home',
                onInit: () => homeInitCount++,
              );
            },
          ),
          ModuleRoute(
            name: 'details',
            path: '/details',
            builder: (_, _, _) => const Scaffold(body: Text('Details')),
          ),
        ]);
        final configurator = GoRouterConfigurator(controller, const []);
        final firstRouter = configurator.createRouter();
        addTearDown(firstRouter.dispose);

        await tester.pumpWidget(MaterialApp.router(routerConfig: firstRouter));
        await tester.pumpAndSettle();
        unawaited(firstRouter.pushNamed<void>('details'));
        await tester.pumpAndSettle();
        final firstNavigatorKey = rootNavigatorKey;

        final secondRouter = configurator.createRouter();
        addTearDown(secondRouter.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: secondRouter));
        await tester.pumpAndSettle();

        expect(rootNavigatorKey, isNot(same(firstNavigatorKey)));
        expect(rootNavigatorKey.currentState, isNotNull);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Details'), findsNothing);
        expect(homeInitCount, 2);
      },
    );

    for (final platform in [TargetPlatform.iOS, TargetPlatform.android]) {
      testWidgets(
        'should use ${kIsWeb ? 'fade transitions' : 'adaptive pages'} when navigating on $platform',
        (tester) async {
          final controller = MockModuleRouteController();
          when(() => controller.redirects).thenReturn(const []);
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
          final router = GoRouterConfigurator(
            controller,
            const [],
          ).createRouter();
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
        when(() => controller.redirects).thenReturn(const []);
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
        final router = configurator.createRouter();

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

    group('requiresAuth', () {
      MockModuleRouteController buildController({
        ModuleRouteRedirect? authRedirect,
      }) {
        final controller = MockModuleRouteController();
        when(() => controller.redirects).thenReturn(const []);
        when(() => controller.authRedirect).thenReturn(authRedirect);
        when(() => controller.allRoutes).thenReturn([
          ModuleRoute(
            name: 'home',
            path: '/',
            builder: (_, _, _) => const Scaffold(body: Text('Home')),
          ),
          ModuleRoute(
            name: 'sign_in',
            path: '/sign-in',
            builder: (_, _, _) => const Scaffold(body: Text('Sign in')),
          ),
          ModuleRoute(
            name: 'private',
            path: '/private',
            requiresAuth: true,
            builder: (_, _, _) => const Scaffold(body: Text('Private')),
          ),
        ]);
        return controller;
      }

      Future<GoRouter> pumpRouter(
        WidgetTester tester,
        MockModuleRouteController controller,
      ) async {
        final router = GoRouterConfigurator(
          controller,
          const [],
        ).createRouter();
        addTearDown(router.dispose);
        await tester.pumpWidget(MaterialApp.router(routerConfig: router));
        await tester.pumpAndSettle();
        return router;
      }

      testWidgets('should open the route when the auth redirect allows it', (
        tester,
      ) async {
        final router = await pumpRouter(
          tester,
          buildController(authRedirect: (_, _) => null),
        );

        router.go('/private');
        await tester.pumpAndSettle();

        expect(find.text('Private'), findsOneWidget);
      });

      testWidgets(
        'should follow the auth redirect when it returns a location',
        (tester) async {
          Uri? guardedUri;
          final router = await pumpRouter(
            tester,
            buildController(
              authRedirect: (_, requestedUri) {
                guardedUri = requestedUri;
                return '/sign-in';
              },
            ),
          );

          router.go('/private?tab=open');
          await tester.pumpAndSettle();

          expect(find.text('Sign in'), findsOneWidget);
          expect(guardedUri, Uri.parse('/private?tab=open'));
        },
      );

      testWidgets('should fall back to the start page when no auth redirect is '
          'registered', (tester) async {
        final router = await pumpRouter(tester, buildController());

        router.go('/private');
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Private'), findsNothing);
      });
    });

    testWidgets(
      'should build the route not found screen when navigation fails',
      (tester) async {
        final controller = MockModuleRouteController();
        final configurator = GoRouterConfigurator(controller, const []);
        when(() => controller.redirects).thenReturn(const []);
        when(() => controller.allRoutes).thenReturn([
          ModuleRoute(
            name: 'home',
            path: '/',
            builder: (_, _, _) => const Scaffold(body: Text('Home')),
          ),
        ]);
        final router = configurator.createRouter();

        await tester.pumpWidget(
          MaterialApp.router(
            routerConfig: router,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            builder: (_, child) {
              return DSThemeBuilderWidget(
                brightness: Brightness.light,
                designSystem: DesignSystem.beltane,
                // The app bar logo loops, so its ticker is muted to let
                // pumpAndSettle finish.
                child: TickerMode(enabled: false, child: child!),
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

class _InitCounterWidget extends StatefulWidget {
  const _InitCounterWidget({required this.label, required this.onInit});

  final String label;
  final VoidCallback onInit;

  @override
  State<_InitCounterWidget> createState() => _InitCounterWidgetState();
}

class _InitCounterWidgetState extends State<_InitCounterWidget> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => Scaffold(body: Text(widget.label));
}
