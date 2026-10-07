import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/route/route.dart';

void main() {
  final homeRoute = ModuleRoute(
    name: 'home',
    path: '/',
    builder: (_, _, _) => const SizedBox.shrink(),
  );
  final middleRoute = ModuleRoute(
    name: 'middle',
    path: '/middle',
    builder: (_, _, _) => const SizedBox.shrink(),
  );
  final detailsRoute = ModuleRoute(
    name: 'details',
    path: '/details',
    builder: (_, _, _) => const SizedBox.shrink(),
  );

  Future<void> pumpRouter(WidgetTester tester) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          name: homeRoute.name,
          path: homeRoute.path,
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                const Text('Home'),
                TextButton(
                  onPressed: () => context.pushScreen(middleRoute),
                  child: const Text('Push middle'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          name: middleRoute.name,
          path: middleRoute.path,
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                const Text('Middle'),
                TextButton(
                  onPressed: context.popScreen,
                  child: const Text('Pop'),
                ),
                TextButton(
                  onPressed: () => context.pushScreen(detailsRoute),
                  child: const Text('Push details'),
                ),
              ],
            ),
          ),
        ),
        GoRoute(
          name: detailsRoute.name,
          path: detailsRoute.path,
          builder: (context, state) => Scaffold(
            body: Column(
              children: [
                const Text('Details'),
                TextButton(
                  onPressed: () => context.popScreenUntil(homeRoute),
                  child: const Text('Pop until home'),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
  }

  group('GoRouteExtension', () {
    testWidgets('should push a named screen when pushScreen is called', (
      tester,
    ) async {
      await pumpRouter(tester);

      await tester.tap(find.text('Push middle'));
      await tester.pumpAndSettle();

      expect(find.text('Middle'), findsOneWidget);
    });

    testWidgets('should pop the current screen when popScreen is called', (
      tester,
    ) async {
      await pumpRouter(tester);

      await tester.tap(find.text('Push middle'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Pop'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets(
      'should pop screens until the requested route is reached when popScreenUntil is called',
      (tester) async {
        await pumpRouter(tester);

        await tester.tap(find.text('Push middle'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Push details'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Pop until home'));
        await tester.pumpAndSettle();

        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
