import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_ask_remote_portfolio_question_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_get_remote_assistant_preference_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_reset_remote_assistant_session_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/domain/use_case/mock_update_remote_assistant_preference_use_case.dart';
import '../../../../../../../mock/feature/remote_assistant/presentation/screen/remote_assistant/tracking/mock_remote_assistant_tracking_delegate.dart';

void main() {
  late MockGetAssistantContextUseCase getContext;
  late MockGetRemoteAssistantPreferenceUseCase getPreference;
  late MockUpdateRemoteAssistantPreferenceUseCase updatePreference;
  late MockResetRemoteAssistantSessionUseCase resetSession;
  late MockAskRemotePortfolioQuestionUseCase askQuestion;
  late MockIsFeatureEnabledUseCase flag;

  const enabled = RemoteAssistantPreferenceEntity(
    enabled: true,
    consentAccepted: true,
  );
  const disabled = RemoteAssistantPreferenceEntity(
    enabled: false,
    consentAccepted: false,
  );

  setUpAll(() {
    registerFallbackValue(disabled);
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
    RemoteAssistantPreferenceEntity preference = enabled,
  }) {
    getContext = MockGetAssistantContextUseCase();
    when(() => getContext()).thenAnswer((_) => const Right('Portfolio'));
    getPreference = MockGetRemoteAssistantPreferenceUseCase();
    when(() => getPreference()).thenAnswer((_) => Right(preference));
    updatePreference = MockUpdateRemoteAssistantPreferenceUseCase();
    when(() => updatePreference(any())).thenAnswer((_) => const Right(null));
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
    flag = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: RemoteAssistantFeatureFlags.remoteAssistant,
        result: Right(rollout),
      );
    final bloc = RemoteAssistantBloc(
      getContext,
      getPreference,
      updatePreference,
      resetSession,
      askQuestion,
      flag,
      MockRemoteAssistantTrackingDelegate(),
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
    'should avoid preference and context access when rollout is off',
    () async {
      final bloc = createBloc(rollout: false);
      bloc.add(const RemoteAssistantStartedEvent());
      await waitFor(
        bloc,
        (state) => state.status == RemoteAssistantStatus.unavailable,
      );
      verifyNever(() => getPreference());
      verifyNever(() => getContext());
      verifyNever(() => askQuestion(any()));
    },
  );

  test(
    'should require consent when the saved preference is disabled',
    () async {
      final bloc = createBloc(preference: disabled);
      bloc.add(const RemoteAssistantStartedEvent());
      await waitFor(bloc, (state) => state.status == RemoteAssistantStatus.off);
      verifyNever(() => getContext());
      bloc.add(const AcceptRemoteAssistantConsentClickEvent());
      await waitFor(
        bloc,
        (state) => state.isReady && state.portfolioContext != null,
      );
      verify(() => updatePreference(enabled)).called(1);
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

  for (final disable in [false, true]) {
    test(
      'should discard late output when ${disable ? 'disable' : 'reset'} occurs during generation',
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
        bloc.add(
          disable
              ? const DisableRemoteAssistantClickEvent()
              : const ResetRemoteAssistantClickEvent(),
        );
        await waitFor(
          bloc,
          (state) => !state.isSendingQuestion && state.messages.isEmpty,
        );
        request.onDelta('Late output');
        pending.complete(const Right(null));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.messages, isEmpty);
        expect(bloc.state.partialAnswer, isEmpty);
        expect(bloc.state.isReady, !disable);
        if (disable) {
          await waitFor(bloc, (state) => !state.isUpdatingPreference);
          verify(() => updatePreference(disabled)).called(1);
        } else {
          verify(() => resetSession()).called(1);
          verifyNever(() => updatePreference(any()));
        }
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
      final reopened = Completer<void>();
      when(() => getPreference()).thenAnswer((_) {
        reopened.complete();
        return const Right(enabled);
      });
      bloc.add(const RemoteAssistantStartedEvent());
      await reopened.future;
      await Future<void>.delayed(Duration.zero);
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
    'should remain off when consent persistence completes after disabling',
    () async {
      final bloc = createBloc(preference: disabled);
      bloc.add(const RemoteAssistantStartedEvent());
      await waitFor(bloc, (state) => state.status == RemoteAssistantStatus.off);
      final enablePending = Completer<Either<RemoteAssistantFailure, void>>();
      when(
        () => updatePreference(enabled),
      ).thenAnswer((_) => enablePending.future);
      bloc.add(const AcceptRemoteAssistantConsentClickEvent());
      await waitFor(bloc, (state) => state.isUpdatingPreference);
      await Future<void>.delayed(Duration.zero);
      bloc.add(const DisableRemoteAssistantClickEvent());
      await waitFor(bloc, (state) => !state.isUpdatingPreference);
      enablePending.complete(const Right(null));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.status, RemoteAssistantStatus.off);
      expect(bloc.state.portfolioContext, isNull);
      verifyNever(() => getContext());
    },
  );
}
