import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/_bloc.dart';
import 'package:portrai/src/feature/force_update/presentation/widget/force_update_listener_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/route.dart';
import 'package:use_case/use_case.dart';

import '../../../../../mock/feature/external_app_handler/domain/use_case/fake_open_external_url_param.dart';
import '../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_get_app_store_url_use_case.dart';
import '../../../../../mock/feature/force_update/domain/use_case/mock_is_app_update_required_use_case.dart';
import '../../../../../mock/feature/force_update/presentation/tracking/mock_force_update_tracking_delegate.dart';
import '../../../../../util/tracking_impression_test_util.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(FakeOpenExternalUrlParam());
  });

  setUp(resetTrackingImpressions);

  group('ForceUpdateListenerWidget', () {
    setUp(() async {
      await appServiceLocator.reset();
    });

    tearDown(() async {
      await appServiceLocator.reset();
    });

    ({
      MockIsAppUpdateRequiredUseCase isAppUpdateRequiredUseCase,
      ForceUpdateBloc bloc,
    })
    buildBloc() {
      final isAppUpdateRequiredUseCase = MockIsAppUpdateRequiredUseCase();
      final getAppStoreUrlUseCase = MockGetAppStoreUrlUseCase()
        ..stubCall(Right(Uri.parse('https://example.com')));
      final openExternalUrlUseCase = MockOpenExternalUrlUseCase()
        ..stubCall(const Right<OpenExternalUrlFailure, bool>(true));
      final trackingDelegate = MockForceUpdateTrackingDelegate();
      final bloc = ForceUpdateBloc(
        isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
        getAppStoreUrlUseCase: getAppStoreUrlUseCase,
        openExternalUrlUseCase: openExternalUrlUseCase,
        trackingDelegate: trackingDelegate,
      );
      return (
        isAppUpdateRequiredUseCase: isAppUpdateRequiredUseCase,
        bloc: bloc,
      );
    }

    Future<void> pumpWidget(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: rootNavigatorKey,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (_, child) {
            return DSThemeBuilderWidget(
              brightness: Brightness.light,
              designSystem: DesignSystem.beltane,
              child: child!,
            );
          },
          home: const ForceUpdateListenerWidget(child: SizedBox.expand()),
        ),
      );
      await tester.pump();
    }

    testWidgets(
      'should request a force update check when the widget is initialized',
      (tester) async {
        final deps = buildBloc();
        deps.isAppUpdateRequiredUseCase.stubCall(
          const Right<IsAppUpdateRequiredFailure, bool>(false),
        );
        appServiceLocator.registerFactory<ForceUpdateBloc>(() => deps.bloc);

        await pumpWidget(tester);

        verify(() => deps.isAppUpdateRequiredUseCase()).called(1);
      },
    );

    testWidgets(
      'should show the force update bottom sheet when an update is required',
      (tester) async {
        final deps = buildBloc();
        deps.isAppUpdateRequiredUseCase.stubCall(
          const Right<IsAppUpdateRequiredFailure, bool>(true),
        );
        appServiceLocator.registerFactory<ForceUpdateBloc>(() => deps.bloc);

        await pumpWidget(tester);
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(ForceUpdateListenerWidget));
        expect(
          find.text(context.localizations.forceUpdateTitle),
          findsOneWidget,
        );
      },
    );

    testWidgets('should re-check the version when the app resumes', (
      tester,
    ) async {
      final deps = buildBloc();
      when(() => deps.isAppUpdateRequiredUseCase()).thenAnswer(
        (_) =>
            Future.value(const Right<IsAppUpdateRequiredFailure, bool>(false)),
      );
      appServiceLocator.registerFactory<ForceUpdateBloc>(() => deps.bloc);

      await pumpWidget(tester);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      verify(() => deps.isAppUpdateRequiredUseCase()).called(2);
    });

    testWidgets(
      'should dismiss the bottom sheet when the update is no longer required after resume',
      (tester) async {
        final deps = buildBloc();
        var callCount = 0;
        when(() => deps.isAppUpdateRequiredUseCase()).thenAnswer((_) {
          callCount += 1;
          return Future.value(
            Right<IsAppUpdateRequiredFailure, bool>(callCount == 1),
          );
        });
        appServiceLocator.registerFactory<ForceUpdateBloc>(() => deps.bloc);

        await pumpWidget(tester);
        await tester.pumpAndSettle();
        expect(find.byType(BottomSheet), findsOneWidget);
        tester.binding.handleAppLifecycleStateChanged(
          AppLifecycleState.resumed,
        );
        await tester.pumpAndSettle();

        expect(find.byType(BottomSheet), findsNothing);
      },
    );
  });
}
