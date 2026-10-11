import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/setting_screen.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:portrai/src/route/observer/route_observer_widget.dart';

import '../../../../../../../mock/feature/setting/presentation/screen/setting/bloc/mock_setting_bloc.dart';
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
    final setting = MockSettingBloc()
      ..stubState(const SettingLoadedState(isLanguageSelectorEnabled: false));
    appServiceLocator.registerFactory<SettingBloc>(() => setting);
    final router = GoRouter(
      observers: [routeObserver],
      routes: [
        GoRoute(path: '/', builder: (_, _) => const SettingScreen()),
        GoRoute(
          path: '/remote-assistant',
          name: 'remote_assistant',
          builder: (_, _) => const RemoteAssistantScreen(),
        ),
      ],
    );

    addTearDown(router.dispose);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: fixture.local),
          BlocProvider.value(value: fixture.remote),
        ],
        child: TestWidgetWrapper(
          routerConfig: router,
          child: const SizedBox.shrink(),
        ),
      ),
    );
    fixture.start();
    await tester.pumpAndSettle();
    return router;
  }

  Finder remoteSwitch() => find.descendant(
    of: find.byType(RemoteAssistantCardWidget),
    matching: find.byType(Switch),
  );

  testWidgets(
    'should refresh settings from flag snapshots when returning from another route',
    (tester) async {
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
      verifyNever(() => fixture.updateRemote(any()));
      verifyNever(() => fixture.updateLocal(any()));
    },
  );

  for (final (localFlag, remoteFlag) in [
    (false, false),
    (true, false),
    (false, true),
    (true, true),
  ]) {
    testWidgets(
      'should show ${remoteFlag
          ? 'remote'
          : localFlag
          ? 'local'
          : 'no'} settings when flags are local=$localFlag remote=$remoteFlag',
      (tester) async {
        final fixture = AssistantTestFixture(
          localRollout: localFlag,
          remoteRollout: remoteFlag,
        );
        await pumpSettings(tester, fixture);
        expect(
          find.byType(LocalAssistantCardWidget),
          localFlag && !remoteFlag ? findsOneWidget : findsNothing,
        );
        expect(
          find.byType(RemoteAssistantCardWidget),
          remoteFlag ? findsOneWidget : findsNothing,
        );
        verifyNever(() => fixture.updateRemote(any()));
        verifyNever(() => fixture.updateLocal(any()));
      },
    );
  }

  testWidgets(
    'should offer remote settings independently when local platform is web',
    (tester) async {
      final fixture = AssistantTestFixture(localSupported: false);
      await pumpSettings(tester, fixture);
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsOneWidget);
    },
  );

  testWidgets(
    'should hide local settings when only local rollout is on an unsupported platform',
    (tester) async {
      final fixture = AssistantTestFixture(
        localSupported: false,
        remoteRollout: false,
      );
      await pumpSettings(tester, fixture);
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsNothing);
    },
  );

  testWidgets(
    'should hide settings without local fallback when remote rollout is unsupported',
    (tester) async {
      final fixture = AssistantTestFixture(
        remoteSupported: false,
        localEnabled: true,
      );
      await pumpSettings(tester, fixture);
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsNothing);
    },
  );

  testWidgets(
    'should require explicit consent without changing local preference when remote is enabled from settings',
    (tester) async {
      final fixture = AssistantTestFixture(localEnabled: true);
      final router = await pumpSettings(tester, fixture);
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      await tester.ensureVisible(remoteSwitch());
      await tester.tap(remoteSwitch());
      await tester.pumpAndSettle();
      expect(find.text('Agree and enable cloud AI'), findsOneWidget);
      verifyNever(() => fixture.updateRemote(any()));
      await tester.tap(find.text('Agree and enable cloud AI'));
      await tester.pumpAndSettle();
      expect(fixture.preference.enabled, isTrue);
      expect(fixture.preference.consentAccepted, isTrue);
      verifyNever(() => fixture.updateLocal(any()));
      router.pop();
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(remoteSwitch()).value, isTrue);
    },
  );

  testWidgets(
    'should reset and withdraw only remote consent when settings controls are used',
    (tester) async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteEnabled: true,
      );
      await pumpSettings(tester, fixture);
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await tester.pumpAndSettle();
      expect(fixture.remote.state.messages, hasLength(2));
      await tester.ensureVisible(find.text('Clear chat'));
      await tester.tap(find.text('Clear chat'));
      await tester.pumpAndSettle();
      expect(fixture.remote.state.messages, isEmpty);
      expect(fixture.preference.consentAccepted, isTrue);
      await tester.ensureVisible(remoteSwitch());
      await tester.tap(remoteSwitch());
      await tester.pumpAndSettle();
      expect(fixture.preference.consentAccepted, isFalse);
      expect(fixture.preference.enabled, isFalse);
      verifyNever(() => fixture.updateLocal(any()));
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(RemoteAssistantCardWidget), findsOneWidget);
    },
  );
}
