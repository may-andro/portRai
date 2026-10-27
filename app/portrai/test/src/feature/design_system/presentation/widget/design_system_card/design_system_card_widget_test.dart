import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/widget/design_system_card/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../../mock/feature/design_system/presentation/widget/design_system_card/bloc/mock_design_system_card_bloc.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  group('DesignSystemCardWidget', () {
    late MockDesignSystemCardBloc bloc;

    setUp(() async {
      await appServiceLocator.reset();
      bloc = MockDesignSystemCardBloc()
        ..stubState()
        ..registerFactory();
    });

    tearDown(() => appServiceLocator.reset());

    Future<void> pumpCard(WidgetTester tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => const Scaffold(body: DesignSystemCardWidget()),
          ),
          GoRoute(
            name: DesignSystemModuleRoute.designSystemGallery.name,
            path: DesignSystemModuleRoute.designSystemGallery.path,
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

    testWidgets('should track the tap and open the theme gallery when the card '
        'is tapped', (tester) async {
      await pumpCard(tester);

      await tester.tap(find.text('App theme'));
      await tester.pumpAndSettle();

      verify(
        () => bloc.add(const DesignSystemCardClickEvent('theme_card')),
      ).called(1);
      expect(find.text('Theme gallery screen'), findsOneWidget);
    });
  });
}
