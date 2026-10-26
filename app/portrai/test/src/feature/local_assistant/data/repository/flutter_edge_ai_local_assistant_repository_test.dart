import 'dart:async';
import 'dart:convert';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/flutter_edge_ai_local_assistant_repository.dart';
import 'package:portrai/src/feature/local_assistant/domain/exception/_exception.dart';

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
      chat.stubReply('Ready');
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

  test('should keep a model that loads while the session resets', () async {
    final model = MockInferenceModel();
    final chat = MockInferenceChat();
    final loaded = Completer<InferenceModel>();
    var loads = 0;
    when(
      () => model.createChat(temperature: 0.2, maxOutputTokens: 16),
    ).thenAnswer((_) async => chat);
    when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
    chat.stubReply('Ready');
    when(() => chat.close()).thenAnswer((_) async {});
    when(() => model.close()).thenAnswer((_) async {});
    final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader((
      _,
    ) {
      loads++;
      return loaded.future;
    });
    addTearDown(repository.dispose);

    final preparation = repository.prepareModel(onProgress: (_) {});
    await pumpEventQueue();
    expect(loads, 1);
    await repository.resetSession();
    loaded.complete(model);
    await preparation;
    await repository.prepareModel(onProgress: (_) {});

    expect(loads, 1);
    verifyNever(() => model.close());
  });

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
          portfolioContext: jsonEncode({
            'profile': {'name': 'Mayank Rai'},
          }),
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
      chat.stubReply('Ready');
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

  test('should name the portfolio owner in the system instruction', () async {
    final model = MockInferenceModel();
    final chat = MockInferenceChat();
    when(
      () => model.createChat(
        systemInstruction: any(named: 'systemInstruction'),
        temperature: any(named: 'temperature'),
        topK: any(named: 'topK'),
        maxOutputTokens: any(named: 'maxOutputTokens'),
      ),
    ).thenAnswer((_) async => chat);
    when(() => chat.addQueryChunk(any())).thenAnswer((_) async {});
    chat.stubReply('Ready');
    when(() => chat.close()).thenAnswer((_) async {});
    when(() => model.close()).thenAnswer((_) async {});
    final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
      (_) async => model,
    );
    addTearDown(repository.dispose);

    await repository.answer(
      question: 'What does she build?',
      portfolioContext: jsonEncode({
        'profile': {'name': 'Jane Doe'},
      }),
    );

    final instruction =
        verify(
              () => model.createChat(
                systemInstruction: captureAny(named: 'systemInstruction'),
                temperature: 0.2,
                topK: 40,
                maxOutputTokens: 512,
              ),
            ).captured.single
            as String;
    expect(instruction, contains("Jane Doe's professional portfolio"));
    expect(instruction, isNot(contains('Mayank')));
  });

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
      chat.stubReply('Ready');
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

    test('should answer a computed fact without loading the model', () async {
      final repository = FlutterEdgeAiLocalAssistantRepository.withModelLoader(
        (_) => throw StateError('Must not load'),
      );
      addTearDown(repository.dispose);

      final answer = await repository.answer(
        question: 'What is his email?',
        portfolioContext: jsonEncode({
          'profile': {'name': 'Mayank Rai', 'email': 'm@x.com'},
        }),
      );

      expect(answer, "Mayank Rai's email is m@x.com.");
    });

    test('should answer a continuation directly after a direct answer', () async {
      final (:repository, :chat) = await prepareRepository();
      final portfolioContext = jsonEncode({
        'profile': {'name': 'Mayank Rai'},
        'experiences': [
          {'company': 'Stuart'},
          {'company': 'Acme'},
        ],
        'overview': [
          'Time per company, overlapping roles counted once: Stuart: 1 year in 1 role (Developer, July 2022 to June 2023). Acme: 2 years in 1 role (Lead, July 2023 to June 2025).',
        ],
      });

      await repository.answer(
        question: 'How long did he work at Stuart?',
        portfolioContext: portfolioContext,
      );
      final followUp = await repository.answer(
        question: 'and at Acme?',
        portfolioContext: portfolioContext,
      );

      expect(followUp, startsWith('Mayank Rai worked at Acme for 2 years'));
      // Only the readiness check reached the model.
      verify(() => chat.addQueryChunk(any())).called(1);
    });

    test('should replace a link the facts do not contain', () async {
      final (:repository, :chat) = await prepareRepository();
      chat.stubStreamedAnswer(
        () => [
          'Play Store: https://p/stuart. GitHub: https://github.com/made-up.',
        ],
      );

      final answer = await repository.answer(
        question: 'Where can I find the Stuart app?',
        portfolioContext: jsonEncode({
          'projects': [
            {
              'title': 'Stuart',
              'links': [
                'Links for the Stuart project in Spain: https://p/stuart.',
              ],
            },
          ],
        }),
      );

      expect(
        answer,
        'Play Store: https://p/stuart. '
        'GitHub: (no link listed in the portfolio).',
      );
    });

    test('should end a cut-off answer at its last full sentence', () async {
      final (:repository, :chat) = await prepareRepository();
      final complete = [
        for (var feature = 0; feature < 100; feature++)
          'Feature $feature shipped.',
      ].join(' ');
      chat.stubStreamedAnswer(() => ['$complete He also wor']);

      final answer = await repository.answer(
        question: 'What did he do at Stuart?',
        portfolioContext: jsonEncode({
          'projects': [
            {'title': 'Stuart'},
          ],
        }),
      );

      expect(answer, complete);
    });

    test('should strip markdown from the generated answer', () async {
      final (:repository, :chat) = await prepareRepository();
      chat.stubStreamedAnswer(
        () => ['**Answer:** He built:\n* the MediaMarkt app\n* the Saturn app'],
      );

      final answer = await repository.answer(
        question: 'What did he build?',
        portfolioContext: jsonEncode({
          'projects': [
            {'title': 'MediaMarkt'},
          ],
        }),
      );

      expect(answer, 'He built:\n- the MediaMarkt app\n- the Saturn app');
    });

    test('should pass the answer on as it is generated', () async {
      final (:repository, :chat) = await prepareRepository();
      chat.stubStreamedAnswer(() => ['**He**', ' builds', ' apps.']);
      final partialAnswers = <String>[];

      final answer = await repository.answer(
        question: 'What does he build?',
        portfolioContext: jsonEncode({
          'projects': [
            {'title': 'Stuart'},
          ],
        }),
        onPartialAnswer: partialAnswers.add,
      );

      expect(partialAnswers, ['He', 'He builds', 'He builds apps.']);
      expect(answer, 'He builds apps.');
    });

    test('should stop the answer being generated on reset', () async {
      final (:repository, :chat) = await prepareRepository();
      final tokens = StreamController<ModelResponse>();
      addTearDown(tokens.close);
      when(chat.generateChatResponseAsync).thenAnswer((_) => tokens.stream);
      when(chat.stopGeneration).thenAnswer((_) async {});
      final firstToken = Completer<void>();

      final answer = repository.answer(
        question: 'What does he build?',
        portfolioContext: jsonEncode({
          'projects': [
            {'title': 'Stuart'},
          ],
        }),
        onPartialAnswer: (_) {
          if (!firstToken.isCompleted) firstToken.complete();
        },
      );
      tokens.add(const TextResponse('He'));
      await firstToken.future;
      await repository.resetSession();
      tokens.add(const TextResponse(' builds'));

      await expectLater(
        answer,
        throwsA(isA<LocalAssistantCancelledException>()),
      );
      verify(chat.stopGeneration).called(1);
    });

    test('should not stop generation on reset without an answer', () async {
      final (:repository, :chat) = await prepareRepository();
      chat.stubStreamedAnswer(() => ['He builds apps.']);
      await repository.answer(
        question: 'What does he build?',
        portfolioContext: jsonEncode({
          'projects': [
            {'title': 'Stuart'},
          ],
        }),
      );

      await repository.resetSession();

      verifyNever(chat.stopGeneration);
    });

    test('should withdraw a looping answer before the retry', () async {
      final (:repository, :chat) = await prepareRepository();
      final answers = [
        ['Mayank Rai', ' Mayank Rai', ' Mayank Rai', ' Mayank Rai'],
        ['He is a Flutter developer.'],
      ];
      chat.stubStreamedAnswer(() => answers.removeAt(0));
      final partialAnswers = <String>[];

      await repository.answer(
        question: 'Who is he?',
        portfolioContext: jsonEncode({
          'profile': {'name': 'Mayank Rai'},
        }),
        onPartialAnswer: partialAnswers.add,
      );

      expect(partialAnswers.last, 'He is a Flutter developer.');
      expect(partialAnswers, contains(''));
      expect(
        partialAnswers,
        isNot(
          contains(startsWith('Mayank Rai Mayank Rai Mayank Rai Mayank Rai')),
        ),
      );
    });

    test('should retry once when the answer repeats a phrase', () async {
      final (:repository, :chat) = await prepareRepository();
      final answers = [
        'Mayank Rai Mayank Rai Mayank Rai Mayank Rai Mayank Rai',
        'He is a Flutter developer.',
      ];
      chat.stubStreamedAnswer(() => [answers.removeAt(0)]);

      final answer = await repository.answer(
        question: 'Who is he?',
        portfolioContext: jsonEncode({
          'profile': {'name': 'Mayank Rai'},
        }),
      );

      expect(answer, 'He is a Flutter developer.');
      expect(answers, isEmpty);
    });

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
