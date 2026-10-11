import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../util/assistant_test_fixture.dart';
import '../../../../../../util/test_wrapper_widget.dart';

void main() {
  setUpAll(AssistantTestFixture.registerFallbacks);

  Future<void> pumpScreen(
    WidgetTester tester,
    AssistantTestFixture fixture,
  ) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        child: BlocProvider.value(
          value: fixture.local,
          child: const LocalAssistantScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final unsupported in [false, true]) {
    testWidgets(
      'should guard direct local entry when ${unsupported ? 'platform is unsupported' : 'rollout is off'}',
      (tester) async {
        final fixture = AssistantTestFixture(
          localRollout: unsupported,
          localSupported: !unsupported,
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
      final fixture = AssistantTestFixture();
      await pumpScreen(tester, fixture);
      expect(find.byType(Switch), findsOneWidget);
      expect(find.byType(AssistantConversationWidget), findsNothing);
      await tester.tap(find.byType(Switch));
      await tester.pumpAndSettle();
      expect(fixture.local.state.isReady, isTrue);
      verify(() => fixture.updateLocal(true)).called(1);
    },
  );

  for (final action in ['disable', 'reset', 'flag off']) {
    test(
      'should discard late local output when $action occurs during a request',
      () async {
        final fixture = AssistantTestFixture(localEnabled: true);
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
        } else if (action == 'reset') {
          fixture.local.add(const ResetLocalAssistantClickEvent());
        } else {
          fixture.setRollout(local: false, remote: true, notify: true);
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
      final fixture = AssistantTestFixture(localEnabled: true);
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
      final fixture = AssistantTestFixture(localEnabled: true);
      fixture.start();
      await pumpEventQueue();
      fixture.setRollout(local: false, remote: true);
      fixture.local.add(const SendLocalAssistantQuestionClickEvent('Question'));
      await pumpEventQueue();
      verifyNever(() => fixture.askLocal(any()));
      expect(fixture.local.state.status, isA<LocalAssistantUnavailable>());
    },
  );
}
