import 'dart:convert';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/flutter_edge_ai_local_assistant_repository.dart';

import '../../../../../mock/feature/local_assistant/data/repository/mock_inference_chat.dart';
import '../../../../../mock/feature/local_assistant/data/repository/mock_inference_model.dart';

void main() {
  setUpAll(() {
    registerFallbackValue(const Message(text: 'Ready', isUser: true));
  });

  test(
    'should reuse the prepared model when readiness inference succeeds',
    () async {
      final model = MockInferenceModel();
      final chat = MockInferenceChat();
      var loads = 0;
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenAnswer((_) async => chat);
      when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
      when(
        () => chat.generateChatResponse(),
      ).thenAnswer((_) async => const TextResponse('Ready'));
      when(() => chat.close()).thenAnswer((_) async {});
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader((
        _,
      ) async {
        loads++;
        return model;
      });
      addTearDown(repository.dispose);

      await repository.prepareModel(onProgress: (_) {});
      await repository.prepareModel(onProgress: (_) {});

      expect(loads, 1);
      verify(() => chat.generateChatResponse()).called(1);
      verify(() => chat.close()).called(1);
    },
  );

  test(
    'should close the failed model and allow retry when engine loading fails',
    () async {
      final model = MockInferenceModel();
      var loads = 0;
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenThrow(StateError('Unsupported model metadata'));
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader((
        _,
      ) async {
        loads++;
        return model;
      });

      for (var attempt = 0; attempt < 2; attempt++) {
        await expectLater(
          repository.prepareModel(onProgress: (_) {}),
          throwsStateError,
        );
      }

      expect(loads, 2);
      verify(() => model.close()).called(2);
      await expectLater(
        repository.answer(
          question: 'Who?',
          portfolioContext: 'Name: Mayank Rai',
        ),
        throwsStateError,
      );
    },
  );

  test(
    'should reject readiness when inference returns an empty answer',
    () async {
      final model = MockInferenceModel();
      final chat = MockInferenceChat();
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenAnswer((_) async => chat);
      when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
      when(
        () => chat.generateChatResponse(),
      ).thenAnswer((_) async => const TextResponse(' '));
      when(() => chat.close()).thenAnswer((_) async {});
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => model,
      );

      await expectLater(
        repository.prepareModel(onProgress: (_) {}),
        throwsStateError,
      );

      verify(() => chat.close()).called(1);
      verify(() => model.close()).called(1);
    },
  );

  test(
    'should send relevant dates when answering a company question',
    () async {
      final model = MockInferenceModel();
      final chat = MockInferenceChat();
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenAnswer((_) async => chat);
      when(
        () => model.createChat(
          systemInstruction: any(named: 'systemInstruction'),
          temperature: 0.2,
          topK: 40,
          maxOutputTokens: 512,
        ),
      ).thenAnswer((_) async => chat);
      when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
      when(
        () => chat.generateChatResponse(),
      ).thenAnswer((_) async => const TextResponse('Ready'));
      when(() => chat.close()).thenAnswer((_) async {});
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => model,
      );
      addTearDown(repository.dispose);
      await repository.prepareModel(onProgress: (_) {});

      await repository.answer(
        question: 'What happened at Stuart?',
        portfolioContext: jsonEncode({
          'experiences': [
            {
              'company': 'Stuart',
              'startDate': '2022-07-01',
              'endDate': '2024-03-31',
              'summary':
                  'Worked as Senior Flutter Developer at Stuart from July '
                  '2022 to March 2024. Total time at Stuart: 1 year and 9 '
                  'months.',
            },
          ],
        }),
      );

      final message =
          verify(() => chat.addQueryChunk(captureAny())).captured.last
              as Message;
      final instruction = message.text;
      expect(instruction, contains('2022-07-01'));
      expect(instruction, contains('2024-03-31'));
      expect(instruction, contains('1 year and 9 months'));
    },
  );

  group('portfolio context', () {
    Future<
      ({
        FlutterEdgeAiLocalAssistantRepository repository,
        MockInferenceChat chat,
      })
    >
    prepareRepository() async {
      final model = MockInferenceModel();
      final chat = MockInferenceChat();
      when(
        () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
      ).thenAnswer((_) async => chat);
      when(
        () => model.createChat(
          systemInstruction: any(named: 'systemInstruction'),
          temperature: any(named: 'temperature'),
          topK: 40,
          maxOutputTokens: 512,
        ),
      ).thenAnswer((_) async => chat);
      when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
      when(
        () => chat.generateChatResponse(),
      ).thenAnswer((_) async => const TextResponse('Ready'));
      when(() => chat.close()).thenAnswer((_) async {});
      when(() => model.close()).thenAnswer((_) async {});
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) async => model,
      );
      addTearDown(repository.dispose);
      await repository.prepareModel(onProgress: (_) {});
      return (repository: repository, chat: chat);
    }

    test(
      'should answer contact questions directly when the context is reused',
      () async {
        final (:repository, :chat) = await prepareRepository();
        final portfolioContext = jsonEncode({
          'profile': {'name': 'Mayank Rai', 'email': 'm@x.com', 'phone': '1'},
        });

        final emailAnswer = await repository.answer(
          question: 'What is his email?',
          portfolioContext: portfolioContext,
        );
        final phoneAnswer = await repository.answer(
          question: 'What is his phone number?',
          portfolioContext: portfolioContext,
        );

        expect(emailAnswer, contains('m@x.com'));
        expect(phoneAnswer, contains('1'));
        // Only the readiness check reached the model.
        verify(() => chat.addQueryChunk(any())).called(1);
      },
    );

    test(
      'should throw a format exception when the context is not a portfolio object and the model is needed',
      () async {
        final (:repository, chat: _) = await prepareRepository();

        await expectLater(
          repository.answer(
            question: 'What happened at Stuart?',
            portfolioContext: 'Name: Mayank Rai',
          ),
          throwsFormatException,
        );
      },
    );

    test(
      'should select facts from the new context when the context changes',
      () async {
        final (:repository, :chat) = await prepareRepository();
        String contextFor(String company) => jsonEncode({
          'experiences': [
            {'company': company, 'startDate': '2022-07-01'},
          ],
        });

        await repository.answer(
          question: 'What happened at Stuart?',
          portfolioContext: contextFor('Stuart'),
        );
        await repository.answer(
          question: 'What happened at Initech?',
          portfolioContext: contextFor('Initech'),
        );

        final message =
            verify(() => chat.addQueryChunk(captureAny())).captured.last
                as Message;
        expect(message.text, contains('Initech'));
        expect(message.text, isNot(contains('Stuart')));
      },
    );
  });
}
