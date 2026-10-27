import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  group('DesignSystemCardWidget', () {
    Future<void> pumpCard(WidgetTester tester, {VoidCallback? onOpen}) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                Scaffold(body: DesignSystemCardWidget(onOpen: onOpen)),
          ),
          GoRoute(
            name: 'design_system_gallery',
            path: '/themes',
            builder: (_, _) => const Text('Theme gallery screen'),
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('should name the theme in use', (tester) async {
      await pumpCard(tester);

      expect(find.text('App theme'), findsOneWidget);
      expect(find.text('Beltane'), findsOneWidget);
    });

    testWidgets('should open the theme gallery and report it when the card '
        'is tapped', (tester) async {
      var openCount = 0;
      await pumpCard(tester, onOpen: () => openCount++);

      await tester.tap(find.text('App theme'));
      await tester.pumpAndSettle();

      expect(find.text('Theme gallery screen'), findsOneWidget);
      expect(openCount, 1);
    });
  });
}
