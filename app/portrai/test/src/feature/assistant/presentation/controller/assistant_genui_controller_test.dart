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
  test('should allow remounting a surface when every surface was released', () {
    final genuiController = AssistantGenuiController();
    addTearDown(genuiController.dispose);

    genuiController.acquireSurface()();

    expect(genuiController.acquireSurface, returnsNormally);
  });

  test('should bound catalog instructions when constructing a session', () {
    final genuiController = AssistantGenuiController();
    addTearDown(genuiController.dispose);
    expect(genuiController.systemPrompt.length, lessThanOrEqualTo(50000));
  });

  testWidgets(
    'should render DS surfaces when the callback streams split A2UI chunks',
    (tester) async {
      final genuiController = AssistantGenuiController();
      addTearDown(genuiController.dispose);
      await tester.pumpWidget(
        TestWidgetWrapper(
          child: Surface(
            surfaceContext: genuiController.surfaceController.contextFor(
              'answer',
            ),
          ),
        ),
      );
      final message = ChatMessage.user('Question');
      await tester.runAsync(() async {
        for (var turn = 0; turn < 2; turn++) {
          final result = await genuiController.send(
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
      expect(genuiController.surfaceController.activeSurfaceIds, [
        'answer',
        'followup',
      ]);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

  test(
    'should preserve domain results when the callback returns a failure',
    () async {
      final genuiController = AssistantGenuiController();
      addTearDown(genuiController.dispose);
      const failure = Left<String, void>('domain failure');
      expect(
        await genuiController.send(
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
      final genuiController = AssistantGenuiController();
      addTearDown(genuiController.dispose);
      final error = StateError('Generation failed');
      await expectLater(
        genuiController.send(
          ChatMessage.user('Question'),
          generate: (_, _, _) async => throw error,
        ),
        throwsA(isA<AssistantGenuiResponseException>()),
      );
      await expectLater(
        genuiController.send(
          ChatMessage.user('Question'),
          generate: (_, _, onDelta) async {
            onDelta('{"version":"v0.9","createSurface":{}}');
          },
        ),
        throwsA(isA<AssistantGenuiResponseException>()),
      );
    },
  );

  testWidgets(
    'should surface framework validation errors without exposing generated payloads',
    (tester) async {
      final genuiController = AssistantGenuiController();
      addTearDown(genuiController.dispose);
      final errors = <ChatMessage>[];
      final subscription = genuiController.surfaceController.onSubmit.listen(
        errors.add,
      );
      addTearDown(subscription.cancel);
      var requests = 0;
      final error = await tester.runAsync<Object?>(() async {
        try {
          await genuiController.send(
            ChatMessage.user('Question'),
            generate: (_, _, onDelta) async {
              requests++;
              onDelta(_surface.replaceFirst('"DSText"', '"Image"'));
            },
          );
          return null;
        } catch (e) {
          return e;
        }
      });
      expect(error, isA<AssistantGenuiResponseException>());
      await tester.pumpAndSettle();
      expect(requests, 1);
      expect(errors, isNotEmpty);
      expect(errors.toString(), isNot(contains('Image')));
    },
  );

  test(
    'should invalidate pending output when reset or disposal occurs',
    () async {
      final genuiController = AssistantGenuiController();
      addTearDown(genuiController.dispose);
      for (final dispose in [false, true]) {
        final gate = Completer<void>();
        late void Function(String) delta;
        final pending = genuiController.send(
          ChatMessage.user('Question'),
          generate: (_, _, onDelta) async {
            delta = onDelta;
            await gate.future;
          },
        );
        delta(_surface);
        await Future<void>.delayed(Duration.zero);
        expect(genuiController.surfaceController.activeSurfaceIds, ['answer']);
        await expectLater(
          genuiController.send(
            ChatMessage.user('Busy'),
            generate: (_, _, _) async {},
          ),
          throwsStateError,
        );
        final expectation = expectLater(
          pending,
          throwsA(isA<AssistantGenuiTurnCancelledException>()),
        );
        if (dispose) {
          genuiController.dispose();
        } else {
          genuiController.reset();
        }
        await expectation;
        delta(_surface);
        gate.complete();
        await Future<void>.delayed(Duration.zero);
        expect(genuiController.surfaceController.activeSurfaceIds, isEmpty);
      }
      await expectLater(
        genuiController.send(
          ChatMessage.user('Closed'),
          generate: (_, _, _) async {},
        ),
        throwsStateError,
      );
    },
  );
}
