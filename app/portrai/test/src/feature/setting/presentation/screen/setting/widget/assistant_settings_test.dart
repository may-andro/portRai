import 'dart:async';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/domain/feature_flag/setting_feature_flags.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/setting_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../../util/package_info_setup.dart';
import '../../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);
  setUp(() async {
    await appServiceLocator.reset();
    registerTestPackageInfo();
  });
  tearDown(() => appServiceLocator.reset());

  Future<GoRouter> pumpSettings(
    WidgetTester tester,
    AssistantTestFixture fixture,
  ) async {
    fixture.install();
    final flag = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: SettingFeatureFlags.languageSelector,
        result: const Right(false),
      );
    appServiceLocator.registerFactory<SettingBloc>(
      () => SettingBloc(
        flag,
        BuildConfig(buildEnvironment: BuildEnvironment.prod),
        fixture.localAvailability,
        fixture.remoteAvailability,
      ),
    );
    final router = GoRouter(
      observers: [routeObserver],
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SettingScreen()),
        GoRoute(
          path: '/remote-assistant',
          name: 'remote_assistant',
          builder: (context, state) => RemoteAssistantModuleRoute.assistant
              .builder(context, state.extra, state.pathParameters),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      TestWidgetWrapper(routerConfig: router, child: const SizedBox.shrink()),
    );
    await tester.pumpAndSettle();
    return router;
  }

  for (final (localFlag, remoteFlag) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    testWidgets(
      'should show only the active provider when flags are local=$localFlag remote=$remoteFlag',
      (tester) async {
        await pumpSettings(
          tester,
          AssistantTestFixture(
            localRollout: localFlag,
            remoteRollout: remoteFlag,
          ),
        );
        expect(
          find.byType(LocalAssistantCardWidget),
          localFlag && !remoteFlag ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(RemoteAssistantCardWidget),
          remoteFlag ? findsOneWidget : findsNothing,
        );
        if (remoteFlag) expect(find.byType(Switch), findsNothing);
      },
    );
  }

  testWidgets(
    'should hide cards without local fallback when remote is unsupported',
    (tester) async {
      await pumpSettings(
        tester,
        AssistantTestFixture(remoteSupported: false, localEnabled: true),
      );
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsNothing);
    },
  );

  testWidgets('should offer remote settings when local is unsupported', (
    tester,
  ) async {
    await pumpSettings(tester, AssistantTestFixture(localSupported: false));
    expect(find.byType(LocalAssistantCardWidget), findsNothing);
    expect(find.byType(RemoteAssistantCardWidget), findsOneWidget);
  });

  testWidgets(
    'should hide local settings when local is unsupported and remote is off',
    (tester) async {
      await pumpSettings(
        tester,
        AssistantTestFixture(localSupported: false, remoteRollout: false),
      );
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsNothing);
    },
  );

  testWidgets('should refresh availability when returning from another route', (
    tester,
  ) async {
    final fixture = AssistantTestFixture();
    final router = await pumpSettings(tester, fixture);
    expect(find.byType(RemoteAssistantCardWidget), findsOneWidget);
    unawaited(router.push('/remote-assistant'));
    await tester.pumpAndSettle();
    fixture.setRollout(local: false, remote: false);
    router.pop();
    await tester.pumpAndSettle();
    expect(find.byType(LocalAssistantCardWidget), findsNothing);
    expect(find.byType(RemoteAssistantCardWidget), findsNothing);
  });

  testWidgets(
    'should open chat without activation controls when the remote card is selected',
    (tester) async {
      await pumpSettings(tester, AssistantTestFixture());
      await tester.ensureVisible(find.text('Ask AI'));
      await tester.tap(find.text('Ask AI'));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
      expect(find.text('Agree and enable cloud AI'), findsNothing);
    },
  );
}
