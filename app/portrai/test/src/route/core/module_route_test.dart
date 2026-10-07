import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/route/route.dart';

void main() {
  group('ModuleRoute', () {
    test('should expose the provided properties when a route is created', () {
      final childRoute = ModuleRoute(
        name: 'details',
        path: 'details',
        builder: (_, _, _) => const SizedBox.shrink(),
      );
      final route = ModuleRoute(
        name: 'home',
        path: '/',
        builder: (_, _, _) => const Text('Home'),
        children: [childRoute],
        requiresAuth: true,
      );

      expect(route.name, 'home');
      expect(route.path, '/');
      expect(route.children, [childRoute]);
      expect(route.requiresAuth, isTrue);
    });

    testWidgets(
      'should use the provided builder when building the route content',
      (tester) async {
        Widget? builtWidget;
        final route = ModuleRoute(
          name: 'home',
          path: '/',
          builder: (context, extra, pathParameters) {
            builtWidget = const Text('Home');
            return builtWidget!;
          },
        );

        await tester.pumpWidget(
          Builder(
            builder: (context) => Directionality(
              textDirection: TextDirection.ltr,
              child: route.builder(context, null, const {}),
            ),
          ),
        );

        expect(builtWidget, isA<Text>());
        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
