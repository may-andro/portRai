import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/job_opening/presentation/widget/_widget.dart';

import '../../../../../util/test_wrapper_widget.dart';

void main() {
  testWidgets('should open the job openings when the card is tapped', (
    tester,
  ) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: JobOpeningsCardWidget()),
        ),
        GoRoute(
          name: 'job_openings',
          path: '/job-openings',
          builder: (_, _) => const Text('Job openings screen'),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Job openings'));
    await tester.pumpAndSettle();

    expect(find.text('Job openings screen'), findsOneWidget);
  });
}
