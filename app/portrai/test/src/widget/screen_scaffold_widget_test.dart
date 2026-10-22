import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';
import 'package:portrai/src/widget/screen_scaffold_widget.dart';

import '../../mock/widget/fake_screen_cubit.dart';
import '../../util/test_wrapper_widget.dart';

void main() {
  setUp(appServiceLocator.reset);
  tearDown(appServiceLocator.reset);

  Future<void> pumpScreen(WidgetTester tester, Widget screen) {
    return tester.pumpWidget(
      MaterialApp(
        navigatorObservers: [routeObserver],
        builder: (context, child) => DSThemeBuilderWidget(
          brightness: Brightness.light,
          designSystem: DesignSystem.beltane,
          child: child!,
        ),
        home: screen,
      ),
    );
  }

  group('ScreenScaffoldWidget', () {
    testWidgets(
      'should create the bloc from the locator and pass it to onCreate when '
      'shown',
      (tester) async {
        final cubit = FakeScreenCubit();
        appServiceLocator.registerFactory<FakeScreenCubit>(() => cubit);

        await pumpScreen(
          tester,
          ScreenScaffoldWidget<FakeScreenCubit, int>(
            onCreate: (bloc) => bloc.add('created'),
            body: const Text('body'),
          ),
        );

        expect(find.text('body'), findsOneWidget);
        expect(find.byType(Scaffold), findsOneWidget);
        expect(cubit.receivedEvents, ['created']);
      },
    );

    testWidgets('should close the bloc when the screen closes', (tester) async {
      final cubit = FakeScreenCubit();
      appServiceLocator.registerFactory<FakeScreenCubit>(() => cubit);
      await pumpScreen(
        tester,
        const ScreenScaffoldWidget<FakeScreenCubit, int>(body: SizedBox()),
      );

      await tester.pumpWidget(const SizedBox());

      expect(cubit.isClosed, isTrue);
    });

    testWidgets(
      'should keep the shared bloc open when the screen closes and the bloc '
      'is retained',
      (tester) async {
        final cubit = FakeScreenCubit();
        addTearDown(cubit.close);
        appServiceLocator.registerSingleton<FakeScreenCubit>(() => cubit);
        await pumpScreen(
          tester,
          const ScreenScaffoldWidget<FakeScreenCubit, int>(
            isRetained: true,
            body: SizedBox(),
          ),
        );

        await tester.pumpWidget(const SizedBox());

        expect(cubit.isClosed, isFalse);
      },
    );

    testWidgets(
      'should call onResume when the screen is shown and again when a route '
      'above it closes',
      (tester) async {
        final cubit = FakeScreenCubit();
        appServiceLocator.registerFactory<FakeScreenCubit>(() => cubit);
        await pumpScreen(
          tester,
          ScreenScaffoldWidget<FakeScreenCubit, int>(
            onResume: (bloc) => bloc.add('resumed'),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const Text('next')),
                ),
                child: const Text('open'),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(cubit.receivedEvents, ['resumed']);

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        Navigator.of(tester.element(find.text('next'))).pop();
        await tester.pumpAndSettle();

        expect(cubit.receivedEvents, ['resumed', 'resumed']);
      },
    );

    testWidgets('should call the listener when the state changes', (
      tester,
    ) async {
      final cubit = FakeScreenCubit();
      appServiceLocator.registerFactory<FakeScreenCubit>(() => cubit);
      final heardStates = <int>[];
      await pumpScreen(
        tester,
        ScreenScaffoldWidget<FakeScreenCubit, int>(
          listenWhen: (previous, current) => current.isEven,
          listener: (_, state) => heardStates.add(state),
          body: const SizedBox(),
        ),
      );

      cubit
        ..count()
        ..count();
      await tester.pump();

      expect(heardStates, [2]);
    });

    testWidgets('should show the body without a scaffold when asked', (
      tester,
    ) async {
      appServiceLocator.registerFactory<FakeScreenCubit>(FakeScreenCubit.new);

      await tester.pumpWidget(
        const TestWidgetWrapper(
          child: ScreenScaffoldWidget<FakeScreenCubit, int>(
            hasScaffold: false,
            body: Text('body'),
          ),
        ),
      );

      expect(find.text('body'), findsOneWidget);
      // Only the wrapper's own scaffold.
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets(
      'should report drawer changes with the bloc when the drawer opens',
      (tester) async {
        final cubit = FakeScreenCubit();
        appServiceLocator.registerFactory<FakeScreenCubit>(() => cubit);
        await pumpScreen(
          tester,
          ScreenScaffoldWidget<FakeScreenCubit, int>(
            drawer: const Drawer(child: Text('drawer')),
            onDrawerChanged: (bloc, isOpened) => bloc.add('drawer $isOpened'),
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('menu'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('menu'));
        await tester.pumpAndSettle();

        expect(cubit.receivedEvents, ['drawer true']);
      },
    );
  });
}
