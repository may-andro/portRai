import 'dart:async';

import 'package:design_system/design_system.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:use_case/use_case.dart';

import '../../../../../util/test_wrapper_widget.dart';

const _surface = '''
{"version":"v0.9","createSurface":{"surfaceId":"answer","catalogId":"dev.portrai.assistant"}}
{"version":"v0.9","updateComponents":{"surfaceId":"answer","components":[
{"id":"root","component":"DSCard","child":"body"},
{"id":"body","component":"DSText","text":"Streamed answer"}]}}
''';

void main() {
  test('should bound catalog instructions when constructing a session', () {
    final session = AssistantGenuiSession();
    addTearDown(session.dispose);
    expect(session.systemPrompt.length, lessThanOrEqualTo(50000));
  });

  testWidgets(
    'should render DS surfaces when the callback streams split A2UI chunks',
    (tester) async {
      final session = AssistantGenuiSession();
      addTearDown(session.dispose);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Surface(
            surfaceContext: session.controller.contextFor('answer'),
          ),
        ),
      );
      final message = ChatMessage.user('Question');
      await tester.runAsync(() async {
        for (var turn = 0; turn < 2; turn++) {
          final result = await session.send(
            message,
            generate: (request, prompt, onDelta) async {
              expect(request, same(message));
              expect(prompt, contains('dev.portrai.assistant'));
              expect(prompt, contains('DSText'));
              expect(prompt, contains('DSCard'));
              expect(prompt, isNot(contains('"component": "Image"')));
              final chunks = turn == 0
                  ? _surface
                  : _surface.replaceAll('"answer"', '"followup"');
              onDelta(chunks.substring(0, 37));
              onDelta(chunks.substring(37));
              return turn;
            },
          );
          expect(result, turn);
        }
      });
      await tester.pumpAndSettle();
      expect(find.byType(DSCardWidget), findsOneWidget);
      expect(find.byType(DSTextWidget), findsOneWidget);
      expect(find.text('Streamed answer'), findsOneWidget);
      expect(session.controller.activeSurfaceIds, ['answer', 'followup']);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'should preserve domain results when the callback returns a failure',
    () async {
      final session = AssistantGenuiSession();
      addTearDown(session.dispose);
      const failure = Left<String, void>('domain failure');
      expect(
        await session.send(
          ChatMessage.user('Question'),
          generate: (_, _, _) async => failure,
        ),
        same(failure),
      );
    },
  );

  test(
    'should propagate errors when generation or official parsing fails',
    () async {
      final session = AssistantGenuiSession();
      addTearDown(session.dispose);
      final error = StateError('Generation failed');
      await expectLater(
        session.send(
          ChatMessage.user('Question'),
          generate: (_, _, _) async => throw error,
        ),
        throwsA(same(error)),
      );
      await expectLater(
        session.send(
          ChatMessage.user('Question'),
          generate: (_, _, onDelta) async {
            onDelta('{"version":"v0.9","createSurface":{}}');
          },
        ),
        throwsA(isA<A2uiValidationException>()),
      );
    },
  );

  testWidgets(
    'should expose controller errors without resending when components are invalid',
    (tester) async {
      final session = AssistantGenuiSession();
      addTearDown(session.dispose);
      final errors = <ChatMessage>[];
      final subscription = session.controller.onSubmit.listen(errors.add);
      addTearDown(subscription.cancel);
      var requests = 0;
      await tester.runAsync(() async {
        await session.send(
          ChatMessage.user('Question'),
          generate: (_, _, onDelta) async {
            requests++;
            onDelta(_surface.replaceFirst('"DSText"', '"Image"'));
          },
        );
      });
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(errors, isNotEmpty);
      expect(
        errors.expand((e) => e.parts.uiInteractionParts).first.interaction,
        contains('VALIDATION_FAILED'),
      );
    },
  );

  test(
    'should invalidate pending output when reset or disposal occurs',
    () async {
      final session = AssistantGenuiSession();
      addTearDown(session.dispose);
      for (final dispose in [false, true]) {
        final gate = Completer<void>();
        late void Function(String) delta;
        final pending = session.send(
          ChatMessage.user('Question'),
          generate: (_, _, onDelta) async {
            delta = onDelta;
            await gate.future;
          },
        );
        delta(_surface);
        await Future<void>.delayed(Duration.zero);
        expect(session.controller.activeSurfaceIds, ['answer']);
        await expectLater(
          session.send(ChatMessage.user('Busy'), generate: (_, _, _) async {}),
          throwsStateError,
        );
        final expectation = expectLater(pending, throwsStateError);
        if (dispose) {
          session.dispose();
        } else {
          session.reset();
        }
        await expectation;
        delta(_surface);
        gate.complete();
        await Future<void>.delayed(Duration.zero);
        expect(session.controller.activeSurfaceIds, isEmpty);
      }
      await expectLater(
        session.send(ChatMessage.user('Closed'), generate: (_, _, _) async {}),
        throwsStateError,
      );
    },
  );
}
