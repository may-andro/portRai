import 'dart:async';

import 'package:firebase/firebase.dart';
import 'package:firebase_ai/firebase_ai.dart'
    show
        BlockReason,
        Candidate,
        FinishReason,
        FirebaseAISdkException,
        GenerateContentResponse,
        PromptFeedback,
        QuotaExceeded,
        ServerException;
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/ai/mock_ai_model_client.dart';

GenerateContentResponse response(
  String text, {
  FinishReason? finishReason = FinishReason.stop,
}) => GenerateContentResponse([
  Candidate(Content.text(text), null, null, finishReason, null),
], null);

void main() {
  setUpAll(() {
    registerFallbackValue(<Content>[]);
  });

  test('should close the owned client once when the model is disposed', () {
    final sdk = MockAiModelClient();
    final model = FbAiTextModel(sdk);
    model.close();
    model.close();
    verify(sdk.close).called(1);
  });

  test('should prevent requests when the model is already closed', () async {
    final sdk = MockAiModelClient();
    final model = FbAiTextModel(sdk)..close();
    await expectLater(
      model.generateText([Content.text('Question')]),
      throwsStateError,
    );
    verifyNever(() => sdk.generateContent(any()));
  });

  for (final (error, matcher) in <(Object, Matcher)>[
    (ClientException('Disconnected'), isA<AiNetworkException>()),
    (TimeoutException('Timeout'), isA<AiTimeoutException>()),
    (FirebaseAISdkException('Invalid response'), isA<AiSdkException>()),
  ]) {
    test(
      'should map request errors when generation throws ${error.runtimeType}',
      () async {
        final sdk = MockAiModelClient()
          ..stubGenerateContentError(error, StackTrace.current);
        await expectLater(
          FbAiTextModel(sdk).generateText([Content.text('Question')]),
          throwsA(matcher),
        );
      },
    );
  }

  test('should return full text when single generation succeeds', () async {
    final sdk = MockAiModelClient()..stubGenerateContent(response('Answer'));
    final prompt = [Content.text('Question')];

    expect(await FbAiTextModel(sdk).generateText(prompt), 'Answer');

    verify(() => sdk.generateContent(prompt)).called(1);
    verifyNever(() => sdk.generateContentStream(any()));
  });

  test(
    'should emit deltas and preserve whitespace when streaming succeeds',
    () async {
      final sdk = MockAiModelClient()
        ..stubGenerateContentStream(
          Stream.fromIterable([
            response('Hello', finishReason: null),
            response(' ', finishReason: null),
            response('world', finishReason: null),
            response(''),
          ]),
        );

      expect(
        await FbAiTextModel(
          sdk,
        ).generateTextStream([Content.text('Question')]).toList(),
        ['Hello', ' ', 'world'],
      );
      verifyNever(() => sdk.generateContent(any()));
    },
  );

  test('should reject the request when prompt content is empty', () async {
    final sdk = MockAiModelClient();
    await expectLater(
      FbAiTextModel(sdk).generateText(const []),
      throwsA(isA<AiInvalidInputException>()),
    );
    await expectLater(
      FbAiTextModel(sdk).generateTextStream(const []).toList(),
      throwsA(isA<AiInvalidInputException>()),
    );
    verifyZeroInteractions(sdk);
  });

  for (final text in ['', '  \n']) {
    test(
      'should report an empty response when generated text is "$text"',
      () async {
        final sdk = MockAiModelClient()..stubGenerateContent(response(text));
        await expectLater(
          FbAiTextModel(sdk).generateText([Content.text('Question')]),
          throwsA(isA<AiEmptyResponseException>()),
        );
      },
    );
  }

  test(
    'should report an empty response when a stream contains only metadata',
    () async {
      final sdk = MockAiModelClient()
        ..stubGenerateContentStream(
          Stream.value(GenerateContentResponse([], null)),
        );
      await expectLater(
        FbAiTextModel(
          sdk,
        ).generateTextStream([Content.text('Question')]).toList(),
        throwsA(isA<AiEmptyResponseException>()),
      );
    },
  );

  test('should reject output when the prompt is blocked', () async {
    final sdk = MockAiModelClient()
      ..stubGenerateContent(
        GenerateContentResponse(
          [],
          PromptFeedback(BlockReason.safety, 'Blocked', []),
        ),
      );
    await expectLater(
      FbAiTextModel(sdk).generateText([Content.text('Question')]),
      throwsA(isA<AiBlockedResponseException>()),
    );
  });

  for (final reason in [
    FinishReason.safety,
    FinishReason.recitation,
    FinishReason.blocklist,
    FinishReason.prohibitedContent,
    FinishReason.spii,
  ]) {
    test(
      'should reject candidate text when its finish reason is $reason',
      () async {
        final sdk = MockAiModelClient()
          ..stubGenerateContent(
            response('Must not display', finishReason: reason),
          );
        await expectLater(
          FbAiTextModel(sdk).generateText([Content.text('Question')]),
          throwsA(isA<AiBlockedResponseException>()),
        );
      },
    );
  }

  test(
    'should report incomplete output when the output token limit is reached',
    () async {
      final sdk = MockAiModelClient()
        ..stubGenerateContent(
          response('Partial', finishReason: FinishReason.maxTokens),
        );
      await expectLater(
        FbAiTextModel(sdk).generateText([Content.text('Question')]),
        throwsA(isA<AiIncompleteResponseException>()),
      );
    },
  );

  test(
    'should report incomplete output when a stream closes without a stop',
    () async {
      final sdk = MockAiModelClient()
        ..stubGenerateContentStream(
          Stream.value(response('Partial', finishReason: null)),
        );
      await expectLater(
        FbAiTextModel(sdk).generateTextStream([Content.text('Question')]),
        emitsInOrder([
          'Partial',
          emitsError(isA<AiIncompleteResponseException>()),
          emitsDone,
        ]),
      );
    },
  );

  test(
    'should surface a block after partial text when streaming is rejected',
    () async {
      final sdk = MockAiModelClient()
        ..stubGenerateContentStream(
          Stream.fromIterable([
            response('Partial', finishReason: null),
            response('Unsafe', finishReason: FinishReason.safety),
          ]),
        );
      await expectLater(
        FbAiTextModel(sdk).generateTextStream([Content.text('Question')]),
        emitsInOrder([
          'Partial',
          emitsError(isA<AiBlockedResponseException>()),
          emitsDone,
        ]),
      );
    },
  );

  test(
    'should preserve quota cause and stack when single generation fails',
    () async {
      final error = QuotaExceeded('Quota exceeded');
      final stack = StackTrace.current;
      final sdk = MockAiModelClient()..stubGenerateContentError(error, stack);
      await expectLater(
        FbAiTextModel(sdk).generateText([Content.text('Question')]),
        throwsA(
          isA<AiQuotaExceededException>()
              .having((e) => e.cause, 'cause', same(error))
              .having((e) => e.stackTrace, 'stackTrace', same(stack))
              .having((e) => e.serviceMessage, 'serviceMessage', error.message),
        ),
      );
    },
  );

  test(
    'should surface quota failures when a stream fails after partial output',
    () async {
      final error = QuotaExceeded('Quota exceeded');
      Stream<GenerateContentResponse> failingStream() async* {
        yield response('Partial', finishReason: null);
        throw error;
      }

      final sdk = MockAiModelClient()
        ..stubGenerateContentStream(failingStream());
      await expectLater(
        FbAiTextModel(sdk).generateTextStream([Content.text('Question')]),
        emitsInOrder([
          'Partial',
          emitsError(
            isA<AiQuotaExceededException>().having(
              (e) => e.serviceMessage,
              'serviceMessage',
              error.message,
            ),
          ),
          emitsDone,
        ]),
      );
    },
  );

  test(
    'should stop delivering deltas when the subscription is cancelled',
    () async {
      var cancelled = false;
      final source = StreamController<GenerateContentResponse>(
        onCancel: () => cancelled = true,
      );
      addTearDown(source.close);
      final sdk = MockAiModelClient()..stubGenerateContentStream(source.stream);
      final first = FbAiTextModel(
        sdk,
      ).generateTextStream([Content.text('Question')]).first;
      source.add(response('First', finishReason: null));

      expect(await first, 'First');
      expect(cancelled, isTrue);
    },
  );

  for (final message in [
    'Your credits are depleted. Enable billing to continue.',
    'Gemini API is disabled. Enable it in the console.',
    'Model gemini-unavailable is not found.',
  ]) {
    for (final streaming in [false, true]) {
      test(
        'should retain server details when generation fails with streaming=$streaming and $message',
        () async {
          final error = ServerException(message);
          final stack = StackTrace.current;
          final sdk = MockAiModelClient();
          if (streaming) {
            sdk.stubGenerateContentStream(
              Stream<GenerateContentResponse>.error(error, stack),
            );
          } else {
            sdk.stubGenerateContentError(error, stack);
          }
          final model = FbAiTextModel(sdk);
          final operation = streaming
              ? model.generateTextStream([
                  Content.text('secret prompt'),
                ]).toList()
              : model.generateText([Content.text('secret prompt')]);
          await expectLater(
            operation,
            throwsA(
              isA<AiServerException>()
                  .having((e) => e.serviceMessage, 'serviceMessage', message)
                  .having((e) => e.cause, 'cause', same(error))
                  .having((e) => e.stackTrace, 'stackTrace', same(stack))
                  .having(
                    (e) => e.toString(),
                    'safe logging',
                    'AiException: Firebase AI request failed',
                  ),
            ),
          );
        },
      );
    }

    for (final error in <Object>[
      FirebaseAISdkException('Unhandled format: secret prompt and response'),
      ClientException(
        'secret body',
        Uri.parse('https://example.com/secret-prompt'),
      ),
    ]) {
      test(
        'should omit non-service diagnostics when streaming fails with ${error.runtimeType}',
        () async {
          final sdk = MockAiModelClient()
            ..stubGenerateContentStream(
              Stream<GenerateContentResponse>.error(error),
            );
          await expectLater(
            FbAiTextModel(
              sdk,
            ).generateTextStream([Content.text('secret prompt')]),
            emitsError(
              isA<AiException>()
                  .having((e) => e.serviceMessage, 'serviceMessage', isNull)
                  .having(
                    (e) => e.toString(),
                    'safe logging',
                    isNot(contains('secret')),
                  ),
            ),
          );
        },
      );
    }

    for (final response in [
      GenerateContentResponse(
        [],
        PromptFeedback(BlockReason.safety, 'secret prompt', []),
      ),
      GenerateContentResponse([], null),
      response('secret generated text', finishReason: FinishReason.maxTokens),
    ]) {
      test(
        'should omit response diagnostics when streaming output is rejected with feedback=${response.promptFeedback?.blockReason} and finish=${response.candidates.firstOrNull?.finishReason}',
        () async {
          final sdk = MockAiModelClient()
            ..stubGenerateContentStream(Stream.value(response));
          await expectLater(
            FbAiTextModel(
              sdk,
            ).generateTextStream([Content.text('secret prompt')]),
            emitsError(
              isA<AiException>()
                  .having((e) => e.serviceMessage, 'serviceMessage', isNull)
                  .having(
                    (e) => e.toString(),
                    'safe logging',
                    isNot(contains('secret')),
                  ),
            ),
          );
        },
      );
    }
  }
}
