import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);

  Future<void> pumpScreen(
    WidgetTester tester,
    AssistantTestFixture fixture,
  ) async {
    await appServiceLocator.reset();
    addTearDown(appServiceLocator.reset);
    fixture.install();
    await tester.pumpWidget(
      const TestWidgetWrapper(child: LocalAssistantScreen()),
    );
    await tester.pumpAndSettle();
  }

  for (final locale in AppLocalizations.supportedLocales) {
    testWidgets(
      'should show the shared localized title and local information when opened in ${locale.languageCode}',
      (tester) async {
        final fixture = AssistantTestFixture(localEnabled: true);
        await appServiceLocator.reset();
        addTearDown(appServiceLocator.reset);
        fixture.install();
        await tester.pumpWidget(
          TestWidgetWrapper(
            child: Builder(
              builder: (context) => Localizations.override(
                context: context,
                locale: locale,
                child: const LocalAssistantScreen(),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final localizations = await AppLocalizations.delegate.load(locale);
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.text(localizations.chatAssistantTitle),
          ),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.text(localizations.chatAssistantTitle),
            matching: find.byType(DSTextWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.descendant(
            of: find.byType(AppBar),
            matching: find.byType(DSIconButtonWidget),
          ),
          findsNWidgets(2),
        );
        expect(
          find.byTooltip(localizations.chatAssistantClear),
          findsOneWidget,
        );
        expect(find.text(localizations.chatAssistantClear), findsNothing);
        expect(
          find.text(localizations.assistantOnDeviceChatDescription),
          findsNothing,
        );
        await tester.tap(find.byTooltip(localizations.assistantOnDeviceBadge));
        await tester.pumpAndSettle();
        expect(find.text(localizations.assistantOnDeviceTitle), findsOneWidget);
        expect(
          find.ancestor(
            of: find.text(localizations.assistantOnDeviceTitle),
            matching: find.byType(DSTextWidget),
          ),
          findsOneWidget,
        );
        expect(
          find.text(localizations.assistantOnDeviceChatDescription),
          findsOneWidget,
        );
        expect(
          find.ancestor(
            of: find.text(localizations.assistantOnDeviceChatDescription),
            matching: find.byType(DSTextWidget),
          ),
          findsOneWidget,
        );
        await tester.tap(find.text(localizations.close));
        await tester.pumpAndSettle();
        expect(
          find.text(localizations.assistantOnDeviceChatDescription),
          findsNothing,
        );
      },
    );
  }

  testWidgets(
    'should clear retained local chat when the toolbar clear action is clicked',
    (tester) async {
      final fixture = AssistantTestFixture(localEnabled: true);
      await pumpScreen(tester, fixture);
      await tester.enterText(find.byType(TextField), 'Question');
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Local answer'), findsOneWidget);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpWidget(
        const TestWidgetWrapper(child: LocalAssistantScreen()),
      );
      await tester.pumpAndSettle();
      expect(find.text('Local answer'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.byTooltip('Clear chat'),
        ),
        findsOneWidget,
      );
      await tester.tap(find.byTooltip('Clear chat'));
      await tester.pumpAndSettle();
      verify(() => fixture.resetLocal()).called(1);
      expect(fixture.local.state.messages, isEmpty);
      expect(find.text('Local answer'), findsNothing);
      expect(find.text('Question'), findsNothing);
      expect(find.text('Clear chat'), findsNothing);
      expect(fixture.local.state.isReady, isTrue);
      expect(fixture.local.state.isModelDownloaded, isTrue);
    },
  );

  for (final unsupported in [false, true]) {
    testWidgets(
      'should guard direct local entry when ${unsupported ? 'platform is unsupported' : 'rollout is off'}',
      (tester) async {
        final fixture = AssistantTestFixture(
          localRollout: unsupported,
          localSupported: !unsupported,
          remoteRollout: false,
        );
        await pumpScreen(tester, fixture);
        expect(find.byType(AssistantConversationWidget), findsNothing);
        expect(find.byType(Switch), findsNothing);
        fixture.local.add(const EnableLocalAssistantClickEvent());
        await tester.pumpAndSettle();
        verifyNever(() => fixture.updateLocal(true));
        verifyNever(() => fixture.context());
      },
    );
  }

  testWidgets(
    'should offer setup rather than blank chat when local is not enabled',
    (tester) async {
      final fixture = AssistantTestFixture(remoteRollout: false);
      await pumpScreen(tester, fixture);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(AssistantConversationWidget), findsNothing);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(fixture.local.state.isReady, isTrue);
      verify(() => fixture.updateLocal(true)).called(1);
    },
  );

  for (final action in ['disable', 'reset']) {
    test(
      'should discard late local output when $action occurs during a request',
      () async {
        final fixture = AssistantTestFixture(
          localEnabled: true,
          remoteRollout: false,
        );
        fixture.start();
        await pumpEventQueue();
        final completion =
            Completer<Either<LocalAssistantFailure, AssistantResponseEntity>>();
        when(
          () => fixture.askLocal(any()),
        ).thenAnswer((_) => completion.future);
        fixture.local.add(
          const SendLocalAssistantQuestionClickEvent('Question'),
        );
        await pumpEventQueue();
        expect(fixture.local.state.isSendingQuestion, isTrue);
        if (action == 'disable') {
          fixture.local.add(
            const DisableLocalAssistantClickEvent(deleteModel: false),
          );
        } else {
          fixture.local.add(const ResetLocalAssistantClickEvent());
        }
        await pumpEventQueue();
        completion.complete(
          const Right(AssistantTextResponseEntity(text: 'Late answer')),
        );
        await pumpEventQueue();
        expect(fixture.local.state.messages, isEmpty);
        expect(fixture.local.state.isSendingQuestion, isFalse);
        expect(fixture.local.state.hasError, isFalse);
      },
    );
  }

  test(
    'should reserve a local request before gating awaits when repeated clicks arrive',
    () async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteRollout: false,
      );
      fixture.start();
      await pumpEventQueue();
      final completion =
          Completer<Either<LocalAssistantFailure, AssistantResponseEntity>>();
      when(() => fixture.askLocal(any())).thenAnswer((_) => completion.future);
      fixture.local
        ..add(const SendLocalAssistantQuestionClickEvent('Question'))
        ..add(const SendLocalAssistantQuestionClickEvent('Question'));
      await pumpEventQueue();
      verify(() => fixture.askLocal(any())).called(1);
      completion.complete(
        const Right(AssistantTextResponseEntity(text: 'Answer')),
      );
      await pumpEventQueue();
    },
  );

  test(
    'should reject new local requests when rollout is switched off after startup',
    () async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteRollout: false,
      );
      fixture.start();
      await pumpEventQueue();
      fixture.setRollout(local: false, remote: true);
      fixture.local.add(const SendLocalAssistantQuestionClickEvent('Question'));
      await pumpEventQueue();
      verifyNever(() => fixture.askLocal(any()));
      expect(fixture.local.state.status, isA<LocalAssistantUnavailable>());
    },
  );

  testWidgets(
    'should retain independent local chat when its route is opened explicitly',
    (tester) async {
      final fixture = AssistantTestFixture(localEnabled: true);
      await pumpScreen(tester, fixture);
      expect(fixture.local.state.isReady, isTrue);
      expect(find.byType(AssistantConversationWidget), findsOneWidget);
      expect(find.byType(Switch), findsNothing);
      verifyNever(() => fixture.updateLocal(true));
      verifyNever(() => fixture.askLocal(any()));
    },
  );

  test(
    'should retain independent local requests when only remote rollout changes',
    () async {
      final fixture = AssistantTestFixture(
        localEnabled: true,
        remoteRollout: false,
      );
      fixture.start();
      await pumpEventQueue();
      fixture.setRollout(local: true, remote: true);
      fixture.local.add(const SendLocalAssistantQuestionClickEvent('Question'));
      await pumpEventQueue();
      verify(() => fixture.askLocal(any())).called(1);
      expect(fixture.local.state.isReady, isTrue);
    },
  );
}
