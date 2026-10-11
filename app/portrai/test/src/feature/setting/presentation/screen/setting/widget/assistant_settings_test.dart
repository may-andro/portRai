import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/setting_state.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/widget/content_widget.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

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
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(
            body: ContentWidget(
              state: SettingLoadedState(isLanguageSelectorEnabled: false),
            ),
          ),
        ),
        GoRoute(
          path: '/remote-assistant',
          name: 'remote_assistant',
          builder: (_, _) => const RemoteAssistantScreen(),
        ),
        GoRoute(
          path: '/assistant',
          name: 'assistant',
          builder: (_, _) => const LocalAssistantScreen(),
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

  Finder cloudSwitch() => find.descendant(
    of: find.byType(RemoteAssistantCardWidget),
    matching: find.byType(Switch),
  );

  testWidgets(
    'should require explicit consent when cloud is enabled from settings',
    (tester) async {
      final fixture = AssistantTestFixture();
      final router = await pumpSettings(tester, fixture);
      expect(find.byType(LocalAssistantCardWidget), findsOneWidget);
      expect(find.byType(RemoteAssistantCardWidget), findsOneWidget);
      await tester.ensureVisible(cloudSwitch());
      await tester.tap(cloudSwitch());
      await tester.pumpAndSettle();
      expect(find.text('Agree and enable cloud AI'), findsOneWidget);
      verifyNever(() => fixture.updateRemote(any()));
      await tester.tap(find.text('Agree and enable cloud AI'));
      await tester.pumpAndSettle();
      expect(fixture.preference.enabled, isTrue);
      expect(fixture.preference.consentAccepted, isTrue);
      expect(fixture.local.state.isEnabled, isFalse);
      router.pop();
      await tester.pumpAndSettle();
      expect(tester.widget<Switch>(cloudSwitch()).value, isTrue);
    },
  );

  testWidgets(
    'should reset and withdraw only cloud consent when settings controls are used',
    (tester) async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteEnabled: true,
      );
      await pumpSettings(tester, fixture);
      fixture.local.add(const SendLocalAssistantQuestionClickEvent('Question'));
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await tester.pumpAndSettle();
      expect(fixture.local.state.messages, hasLength(2));
      expect(fixture.remote.state.messages, hasLength(2));
      await tester.ensureVisible(find.text('Clear chat'));
      await tester.tap(find.text('Clear chat'));
      await tester.pumpAndSettle();
      expect(fixture.remote.state.messages, isEmpty);
      expect(fixture.preference.consentAccepted, isTrue);
      expect(fixture.local.state.messages, hasLength(2));
      await tester.ensureVisible(cloudSwitch());
      await tester.tap(cloudSwitch());
      await tester.pumpAndSettle();
      expect(fixture.preference.consentAccepted, isFalse);
      expect(fixture.preference.enabled, isFalse);
      expect(fixture.local.state.isReady, isTrue);
      expect(fixture.local.state.messages, hasLength(2));
    },
  );

  testWidgets(
    'should retain independent conversations when navigating between screens and settings',
    (tester) async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteEnabled: true,
      );
      final router = await pumpSettings(tester, fixture);
      fixture.local.add(const SendLocalAssistantQuestionClickEvent('Question'));
      fixture.remote.add(
        const SendRemoteAssistantQuestionClickEvent('Question'),
      );
      await tester.pumpAndSettle();
      unawaited(router.push('/assistant'));
      await tester.pumpAndSettle();
      expect(find.text('Local answer'), findsOneWidget);
      expect(find.text('Cloud answer'), findsNothing);
      router.pop();
      await tester.pumpAndSettle();
      unawaited(router.push('/remote-assistant'));
      await tester.pumpAndSettle();
      expect(find.text('Cloud answer'), findsOneWidget);
      expect(find.text('Local answer'), findsNothing);
      router.pop();
      await tester.pumpAndSettle();
      expect(fixture.local.state.messages, hasLength(2));
      expect(fixture.remote.state.messages, hasLength(2));
    },
  );

  testWidgets(
    'should hide settings controls when rollout changes while another route is open',
    (tester) async {
      final fixture = AssistantTestFixture();
      final router = await pumpSettings(tester, fixture);
      unawaited(router.push('/remote-assistant'));
      await tester.pumpAndSettle();
      fixture.setRollout(local: false, remote: false, notify: true);
      await tester.pumpAndSettle();
      router.pop();
      await tester.pumpAndSettle();
      expect(find.byType(LocalAssistantCardWidget), findsNothing);
      expect(find.byType(Switch), findsNothing);
    },
  );
}
