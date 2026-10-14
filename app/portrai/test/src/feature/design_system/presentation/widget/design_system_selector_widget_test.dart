import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/design_system.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/design_system/domain/use_case/mock_get_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_reset_design_system_use_case.dart';
import '../../../../../mock/feature/design_system/domain/use_case/mock_set_design_system_use_case.dart';
import '../../../../../util/test_wrapper_widget.dart';

void main() {
  var restartCount = 0;

  setUp(() => restartCount = 0);

  Future<void> pumpSelector(
    WidgetTester tester, {
    DesignSystem? designSystem,
    Brightness brightness = Brightness.light,
    Either<ResetDesignSystemFailure, void> resetDesignSystemEither =
        const Right(null),
  }) async {
    final getDesignSystemUseCase = MockGetDesignSystemUseCase()
      ..stubCall(designSystem);
    final setDesignSystemUseCase = MockSetDesignSystemUseCase()
      ..registerFallbacks()
      ..stubCall(const Right(null));
    final resetDesignSystemUseCase = MockResetDesignSystemUseCase()
      ..stubCall(resetDesignSystemEither);
    final bloc = DesignSystemBloc(
      getDesignSystemUseCase,
      setDesignSystemUseCase,
      resetDesignSystemUseCase,
    );
    appServiceLocator.registerFactory<DesignSystemBloc>(() => bloc);
    addTearDown(appServiceLocator.reset);
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: DSThemeBuilderWidget(
          brightness: brightness,
          designSystem: DesignSystem.beltane,
          child: Scaffold(
            body: DesignSystemSelectorWidget(
              onRestart: () async => restartCount++,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'should disable reset and not restart when no design system is cached',
    (tester) async {
      await pumpSelector(tester);

      final resetTile = tester.widget<ListTile>(
        find.widgetWithText(ListTile, 'Reset design system'),
      );
      expect(resetTile.enabled, isFalse);
      expect(resetTile.onTap, isNull);

      await tester.tap(find.text('Reset design system'));
      await tester.pumpAndSettle();

      expect(restartCount, 0);
      expect(find.text('Restart').hitTestable(), findsNothing);
    },
  );

  testWidgets(
    'should display the stored selection without a restart message when loaded',
    (tester) async {
      await pumpSelector(tester, designSystem: DesignSystem.holi);
      expect(
        tester
            .widget<DropdownButton<DesignSystem>>(
              find.byType(DropdownButton<DesignSystem>),
            )
            .value,
        DesignSystem.holi,
      );
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Restart').hitTestable(), findsNothing);
      expect(
        tester
            .widget<ListTile>(
              find.widgetWithText(ListTile, 'Reset design system'),
            )
            .enabled,
        isTrue,
      );
    },
  );

  testWidgets(
    'should save the selection and show a restart message when a design system is chosen',
    (tester) async {
      await pumpSelector(tester);
      await tester.tap(find.byType(DropdownButton<DesignSystem>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('holi').last);
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<DesignSystem>>(
              find.byType(DropdownButton<DesignSystem>),
            )
            .value,
        DesignSystem.holi,
      );
      expect(find.byType(SnackBar), findsNothing);
      expect(find.text('Restart').hitTestable(), findsOneWidget);
      expect(
        find
            .text('Restart the app to apply the new design system')
            .hitTestable(),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'should restore automatic selection and restart immediately when reset is tapped',
    (tester) async {
      await pumpSelector(tester, designSystem: DesignSystem.holi);
      await tester.tap(find.text('Reset design system'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<DesignSystem>>(
              find.byType(DropdownButton<DesignSystem>),
            )
            .value,
        isNull,
      );
      expect(find.byType(SnackBar), findsNothing);
      expect(restartCount, 1);
      expect(find.text('Restart').hitTestable(), findsNothing);
      expect(
        find
            .text('Restart the app to apply the new design system')
            .hitTestable(),
        findsNothing,
      );
    },
  );

  testWidgets(
    'should restart directly without showing a restart button when resetting in dark mode',
    (tester) async {
      await pumpSelector(
        tester,
        designSystem: DesignSystem.holi,
        brightness: Brightness.dark,
      );
      await tester.tap(find.text('Reset design system'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsNothing);
      expect(restartCount, 1);
      expect(find.text('Restart').hitTestable(), findsNothing);
      expect(
        find
            .text('Restart the app to apply the new design system')
            .hitTestable(),
        findsNothing,
      );
    },
  );

  testWidgets(
    'should keep the selection and show the failure message when resetting fails',
    (tester) async {
      await pumpSelector(
        tester,
        designSystem: DesignSystem.holi,
        resetDesignSystemEither: const Left(ResetDesignSystemUnknownFailure()),
      );
      await tester.tap(find.text('Reset design system'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<DesignSystem>>(
              find.byType(DropdownButton<DesignSystem>),
            )
            .value,
        DesignSystem.holi,
      );
      expect(find.byType(SnackBar), findsOneWidget);
      expect(restartCount, 0);
      expect(
        find.text('Something went wrong. Please try again'),
        findsOneWidget,
      );
      expect(
        find
            .text('Restart the app to apply the new design system')
            .hitTestable(),
        findsNothing,
      );
    },
  );
}
