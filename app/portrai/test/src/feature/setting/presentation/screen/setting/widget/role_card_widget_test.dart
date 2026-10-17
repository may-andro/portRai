import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/onboarding/onboarding.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/role_card_widget.dart';

import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('RoleCardWidget', () {
    testWidgets(
      'should show the change role label and current role when built',
      (tester) async {
        await tester.pumpWidget(
          const TestWidgetWrapper(
            child: RoleCardWidget(role: UserRole.recruiter),
          ),
        );
        await tester.pump();

        expect(find.text('Change role'), findsOneWidget);
        expect(find.text("I'm a recruiter"), findsOneWidget);
      },
    );

    testWidgets('should open the onboarding screen when tapped', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) =>
                const Scaffold(body: RoleCardWidget(role: UserRole.developer)),
          ),
          GoRoute(
            path: OnboardingModuleRoute.onboarding.path,
            name: OnboardingModuleRoute.onboarding.name,
            builder: (_, _) => const Text('onboarding screen'),
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        TestWidgetWrapper(routerConfig: router, child: const SizedBox()),
      );
      await tester.pump();
      await tester.tap(find.text('Change role'));
      await tester.pumpAndSettle();

      expect(find.text('onboarding screen'), findsOneWidget);
    });
  });
}
