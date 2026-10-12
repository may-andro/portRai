import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../../../../../../../mock/feature/external_app_handler/domain/use_case/mock_open_external_url_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_ask_remote_portfolio_question_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_is_remote_assistant_supported_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_reset_remote_assistant_session_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/presentation/screen/remote_assistant/tracking/mock_remote_assistant_tracking_delegate.dart';

void main() {
  const genuiResponse = '''
Portfolio summary.
```json
{"version":"v0.9","createSurface":{"surfaceId":"answer","catalogId":"dev.portrai.assistant"}}
```
```json
{"version":"v0.9","updateComponents":{"surfaceId":"answer","components":[
{"id":"root","component":"DSCard","child":"body"},
{"id":"body","component":"DSText","text":"Generated answer"}]}}
```
''';

  late MockGetAssistantContextUseCase getContext;
  late MockResetRemoteAssistantSessionUseCase resetSession;
  late MockAskRemotePortfolioQuestionUseCase askQuestion;
  late MockOpenExternalUrlUseCase openUrl;
  late MockRemoteAssistantTrackingDelegate tracking;
  late MockIsFeatureEnabledUseCase flag;
  late MockIsRemoteAssistantSupportedUseCase platformSupport;

  setUpAll(() {
    registerFallbackValue(OpenExternalUrlParam(Uri()));
    registerFallbackValue(
      AskRemotePortfolioQuestionParams(
        question: 'Question',
        portfolioContext: 'Portfolio',
        history: const [],
        onDelta: (_) {},
      ),
    );
  });

  RemoteAssistantBloc createBloc({
    bool rollout = true,
    bool generativeUi = false,
    bool platformSupported = true,
  }) {
    getContext = MockGetAssistantContextUseCase();
    when(() => getContext()).thenAnswer((_) => const Right('Portfolio'));
    resetSession = MockResetRemoteAssistantSessionUseCase();
    when(() => resetSession()).thenAnswer((_) => const Right(null));
    askQuestion = MockAskRemotePortfolioQuestionUseCase();
    when(() => askQuestion(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single
              as AskRemotePortfolioQuestionParams;
      params.onDelta('Answer');
      return const Right(null);
    });
    openUrl = MockOpenExternalUrlUseCase()..stubCall(const Right(true));
    flag = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        result: Right(rollout),
      )
      ..stubCall(
        definition: RemoteAssistantFeatureFlags.generativeUi,
        result: Right(generativeUi),
      );
    platformSupport = MockIsRemoteAssistantSupportedUseCase()
      ..stubCall(Right(platformSupported));
    tracking = MockRemoteAssistantTrackingDelegate();
    final bloc = RemoteAssistantBloc(
      getContext,
      resetSession,
      askQuestion,
      flag,
      platformSupport,
      openUrl,
      tracking,
    );
    addTearDown(bloc.close);
    return bloc;
  }

  Future<void> waitFor(
    RemoteAssistantBloc bloc,
    bool Function(RemoteAssistantState) predicate,
  ) async {
    if (predicate(bloc.state)) return;
    await bloc.stream.firstWhere(predicate).timeout(const Duration(seconds: 3));
  }

  Future<void> start(RemoteAssistantBloc bloc) async {
    bloc.add(const RemoteAssistantStartedEvent());
    await waitFor(
      bloc,
      (state) => state.isReady && state.portfolioContext != null,
    );
  }

  test(
    'should open the external url when a link click event is added',
    () async {
      final bloc = createBloc();
      bloc.add(
        const OpenRemoteAssistantLinkClickEvent('https://example.com/a'),
      );
      await Future<void>.delayed(Duration.zero);
      final param =
          verify(() => openUrl(captureAny())).captured.single
              as OpenExternalUrlParam;
      expect(param.uri, Uri.parse('https://example.com/a'));
      verify(() => tracking.trackLinkClick()).called(1);
    },
  );

  test(
    'should track a suggestion instead of a submission when a chip is tapped',
    () async {
      final bloc = createBloc();
      await start(bloc);

      bloc.add(
        const SendRemoteAssistantQuestionClickEvent(
          'Where did you work?',
          isSuggestion: true,
        ),
      );
      await waitFor(
        bloc,
        (state) => state.messages.length == 2 && !state.isSendingQuestion,
      );

      verify(() => tracking.trackSuggestionClick()).called(1);
      verifyNever(() => tracking.trackQuestionSubmission());
    },
  );

  test('should avoid context and model access when rollout is off', () async {
    final bloc = createBloc(rollout: false);
    bloc.add(const RemoteAssistantStartedEvent());
    await waitFor(
      bloc,
      (state) => state.status == RemoteAssistantStatus.unavailable,
    );
    verifyNever(() => getContext());
    verifyNever(() => askQuestion(any()));
  });

  test(
    'should avoid context and model access when platform support is unavailable',
    () async {
      final bloc = createBloc(platformSupported: false);
      bloc.add(const RemoteAssistantStartedEvent());
      await waitFor(
        bloc,
        (state) => state.status == RemoteAssistantStatus.unavailable,
      );
      verifyNever(() => getContext());
      verifyNever(() => askQuestion(any()));
    },
  );

  test(
    'should activate without a preference when the rollout flag is on',
    () async {
      final bloc = createBloc();
      bloc.add(const RemoteAssistantStartedEvent());
      await waitFor(
        bloc,
        (state) => state.isReady && state.portfolioContext != null,
      );
      verify(() => getContext()).called(1);
      verifyNever(() => askQuestion(any()));
    },
  );

  test(
    'should append streamed text when the remote answer completes',
    () async {
      final bloc = createBloc();
      await start(bloc);
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta('Answer');
        params.onDelta(' with spaces');
        return const Right(null);
      });
      bloc.add(const SendRemoteAssistantQuestionClickEvent('  Question  '));
      await waitFor(
        bloc,
        (state) => state.messages.length == 2 && !state.isSendingQuestion,
      );
      expect(
        bloc.state.messages.last.content,
        const AssistantTextResponseEntity(text: 'Answer with spaces'),
      );
      expect(bloc.state.partialAnswer, isEmpty);
      expect(bloc.state.failure, isNull);
    },
  );

  test(
    'should keep parsed prose and per-turn surfaces when GenUI is enabled',
    () async {
      final bloc = createBloc(generativeUi: true);
      await start(bloc);
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta(genuiResponse);
        return const Right(null);
      });
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(
        bloc,
        (state) => state.messages.length == 2 && !state.isSendingQuestion,
      );

      expect(
        bloc.state.messages.last.content,
        const AssistantTextResponseEntity(text: 'Portfolio summary.'),
      );
      expect(bloc.state.genuiSurfaces, hasLength(1));
      expect(bloc.state.genuiSurfaces.single.surfaceId, 'answer');
      expect(bloc.state.genuiSurfaces.single.messageIndex, 1);
      expect(bloc.state.genuiSurfaces.single.genuiController.activeSurfaceIds, [
        'answer',
      ]);
      expect(
        bloc.state.messages.last.content.toString(),
        isNot(contains('createSurface')),
      );
    },
  );

  test(
    'should return a typed incomplete failure for malformed GenUI output',
    () async {
      final bloc = createBloc(generativeUi: true);
      await start(bloc);
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta('{"version":"v0.9","createSurface":{}}');
        return const Right(null);
      });
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(bloc, (state) => state.failure != null);

      expect(bloc.state.failure, isA<RemoteAssistantIncompleteFailure>());
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.genuiSurfaces, isEmpty);
      expect(bloc.state.partialAnswer, isEmpty);
    },
  );

  test(
    'should discard provisional surfaces and text when GenUI generation fails',
    () async {
      final bloc = createBloc(generativeUi: true);
      await start(bloc);
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta(genuiResponse);
        return const Left<RemoteAssistantFailure, void>(
          RemoteAssistantNetworkFailure(),
        );
      });
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(bloc, (state) => state.failure != null);

      expect(bloc.state.failure, isA<RemoteAssistantNetworkFailure>());
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.genuiSurfaces, isEmpty);
      expect(bloc.state.partialAnswer, isEmpty);
    },
  );

  test(
    'should block duplicate requests when a generation is pending',
    () async {
      final bloc = createBloc();
      await start(bloc);
      final pending = Completer<Either<RemoteAssistantFailure, void>>();
      when(() => askQuestion(any())).thenAnswer((_) => pending.future);
      bloc
        ..add(const SendRemoteAssistantQuestionClickEvent('First'))
        ..add(const SendRemoteAssistantQuestionClickEvent('Second'));
      await waitFor(bloc, (state) => state.messages.isNotEmpty);
      await Future<void>.delayed(Duration.zero);
      verify(() => askQuestion(any())).called(1);
      pending.complete(const Right(null));
    },
  );

  for (final flagOff in [false, true]) {
    test(
      'should discard late output when ${flagOff ? 'flag off' : 'reset'} occurs during generation',
      () async {
        final bloc = createBloc();
        await start(bloc);
        final pending = Completer<Either<RemoteAssistantFailure, void>>();
        late AskRemotePortfolioQuestionParams request;
        when(() => askQuestion(any())).thenAnswer((invocation) {
          request =
              invocation.positionalArguments.single
                  as AskRemotePortfolioQuestionParams;
          request.onDelta('Partial');
          return pending.future;
        });
        bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
        await waitFor(bloc, (state) => state.partialAnswer == 'Partial');
        if (flagOff) {
          flag.stubCall(
            definition: RemoteAssistantFeatureFlags.remoteAssistant,
            result: const Right(false),
          );
          bloc.add(const RemoteAssistantInitializedEvent());
        } else {
          bloc.add(const ResetRemoteAssistantClickEvent());
        }
        await waitFor(
          bloc,
          (state) => !state.isSendingQuestion && state.messages.isEmpty,
        );
        request.onDelta('Late output');
        pending.complete(const Right(null));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.messages, isEmpty);
        expect(bloc.state.partialAnswer, isEmpty);
        expect(bloc.state.isReady, !flagOff);
        verify(() => resetSession()).called(1);
      },
    );
  }

  test(
    'should retain independent chat history when the screen is opened again',
    () async {
      final bloc = createBloc();
      await start(bloc);
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(
        bloc,
        (state) => state.messages.length == 2 && !state.isSendingQuestion,
      );
      final messages = bloc.state.messages;
      bloc.add(const RemoteAssistantStartedEvent());
      await pumpEventQueue();
      expect(bloc.state.messages, messages);
      verify(() => getContext()).called(1);
    },
  );

  test(
    'should bound provider history when more than six turns are visible',
    () async {
      final bloc = createBloc();
      await start(bloc);
      final histories = <List<AssistantMessageEntity>>[];
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        histories.add(params.history);
        params.onDelta('Answer');
        return const Right(null);
      });
      for (var turn = 0; turn < 8; turn++) {
        bloc.add(SendRemoteAssistantQuestionClickEvent('Question $turn'));
        await waitFor(
          bloc,
          (state) =>
              state.messages.length == (turn + 1) * 2 &&
              !state.isSendingQuestion,
        );
      }
      expect(bloc.state.messages.length, 16);
      expect(histories.last.length, 12);
      expect(
        histories.last.first.content,
        const AssistantTextResponseEntity(text: 'Question 1'),
      );
    },
  );

  test(
    'should invalidate a chat when rollout is disabled before the next question',
    () async {
      final bloc = createBloc();
      await start(bloc);
      flag.stubCall(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        result: const Right(false),
      );
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(
        bloc,
        (state) => state.status == RemoteAssistantStatus.unavailable,
      );
      verifyNever(() => askQuestion(any()));
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.isSendingQuestion, isFalse);
    },
  );

  test(
    'should reject a question when platform support changes before submission',
    () async {
      final bloc = createBloc();
      await start(bloc);
      platformSupport.stubCall(const Right(false));
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(
        bloc,
        (state) => state.status == RemoteAssistantStatus.unavailable,
      );
      verifyNever(() => askQuestion(any()));
      expect(bloc.state.isSendingQuestion, isFalse);
    },
  );

  test('should discard provisional text when generation fails', () async {
    final bloc = createBloc();
    await start(bloc);
    when(() => askQuestion(any())).thenAnswer((invocation) {
      final params =
          invocation.positionalArguments.single
              as AskRemotePortfolioQuestionParams;
      params.onDelta('Incomplete answer');
      return const Left<RemoteAssistantFailure, void>(
        RemoteAssistantIncompleteFailure(),
      );
    });
    bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
    await waitFor(bloc, (state) => state.failure != null);
    expect(bloc.state.partialAnswer, isEmpty);
    expect(bloc.state.messages, isEmpty);
    expect(bloc.state.isSendingQuestion, isFalse);
  });

  test(
    'should clear GenUI surfaces and ignore late output when its flag is disabled',
    () async {
      final bloc = createBloc(generativeUi: true);
      await start(bloc);
      final pending = Completer<Either<RemoteAssistantFailure, void>>();
      when(() => askQuestion(any())).thenAnswer((invocation) {
        final params =
            invocation.positionalArguments.single
                as AskRemotePortfolioQuestionParams;
        params.onDelta(genuiResponse);
        return pending.future;
      });
      bloc.add(const SendRemoteAssistantQuestionClickEvent('Question'));
      await waitFor(bloc, (state) => state.genuiSurfaces.isNotEmpty);
      flag.stubCall(
        definition: RemoteAssistantFeatureFlags.generativeUi,
        result: const Right(false),
      );
      bloc.add(const RemoteAssistantInitializedEvent());
      await waitFor(
        bloc,
        (state) =>
            !state.isSendingQuestion &&
            state.messages.isEmpty &&
            !state.isGenerativeUiEnabled,
      );
      pending.complete(const Right(null));
      await pumpEventQueue();

      expect(bloc.state.genuiSurfaces, isEmpty);
      expect(bloc.state.messages, isEmpty);
      expect(bloc.state.partialAnswer, isEmpty);
    },
  );
}
