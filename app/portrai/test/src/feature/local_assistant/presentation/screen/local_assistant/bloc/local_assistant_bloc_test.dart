import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/local_assistant/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/ask_local_portfolio_question_use_case.dart';
import 'package:portrai/src/feature/local_assistant/domain/use_case/local_assistant_failure.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_ask_local_portfolio_question_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_cancel_local_assistant_preparation_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_delete_local_assistant_model_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_get_local_assistant_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_is_local_assistant_model_downloaded_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_prepare_local_assistant_model_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/domain/use_case/mock_update_local_assistant_enabled_use_case.dart';
import '../../../../../../../mock/feature/local_assistant/presentation/screen/local_assistant/tracking/mock_local_assistant_tracking_delegate.dart';

void main() {
  late MockGetLocalAssistantEnabledUseCase getEnabled;
  late MockIsLocalAssistantModelDownloadedUseCase isDownloaded;
  late MockUpdateLocalAssistantEnabledUseCase updateEnabled;
  late MockPrepareLocalAssistantModelUseCase prepare;
  late MockCancelLocalAssistantPreparationUseCase cancel;
  late MockDeleteLocalAssistantModelUseCase delete;
  late MockIsFeatureEnabledUseCase isFeatureEnabled;
  late MockAskLocalPortfolioQuestionUseCase askQuestion;

  setUpAll(() {
    registerFallbackValue((int _) {});
  });

  LocalAssistantBloc createBloc() {
    askQuestion = MockAskLocalPortfolioQuestionUseCase();
    getEnabled = MockGetLocalAssistantEnabledUseCase();
    updateEnabled = MockUpdateLocalAssistantEnabledUseCase();
    prepare = MockPrepareLocalAssistantModelUseCase();
    cancel = MockCancelLocalAssistantPreparationUseCase();
    delete = MockDeleteLocalAssistantModelUseCase();
    when(() => getEnabled()).thenAnswer((_) => const Right(false));
    when(() => updateEnabled(any())).thenAnswer((_) => const Right(null));
    when(() => prepare(any())).thenAnswer((_) => const Right(null));
    when(() => cancel()).thenAnswer((_) => const Right(null));
    when(() => delete()).thenAnswer((_) => const Right(null));
    isDownloaded = MockIsLocalAssistantModelDownloadedUseCase();
    when(() => isDownloaded()).thenAnswer((_) => const Right(false));
    isFeatureEnabled = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        result: const Right(true),
      );
    return LocalAssistantBloc(
      MockGetAssistantContextUseCase(),
      prepare,
      getEnabled,
      updateEnabled,
      cancel,
      delete,
      isDownloaded,
      askQuestion,
      MockLocalAssistantTrackingDelegate(),
      isFeatureEnabled,
    );
  }

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should append typed messages when a portfolio question succeeds',
    build: () {
      final bloc = createBloc();
      askQuestion.stubCall(
        params: const AskLocalPortfolioQuestionParams(
          question: 'Question',
          portfolioContext: 'Context',
        ),
        result: const Right(AssistantTextResponseEntity(text: 'Answer')),
      );
      return bloc;
    },
    seed: () => const LocalAssistantState(
      status: LocalAssistantReady(),
      portfolioContext: 'Context',
      isLoadingContext: false,
    ),
    act: (bloc) =>
        bloc.add(const SendLocalAssistantQuestionClickEvent('  Question  ')),
    expect: () => [
      const LocalAssistantState(
        status: LocalAssistantReady(),
        portfolioContext: 'Context',
        isLoadingContext: false,
        isSendingQuestion: true,
        messages: [
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Question'),
            isUser: true,
          ),
        ],
      ),
      const LocalAssistantState(
        status: LocalAssistantReady(),
        portfolioContext: 'Context',
        isLoadingContext: false,
        messages: [
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Question'),
            isUser: true,
          ),
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Answer'),
            isUser: false,
          ),
        ],
      ),
    ],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should discard the failed turn and expose a failure when answering fails',
    build: () {
      final bloc = createBloc();
      askQuestion.stubCall(
        params: const AskLocalPortfolioQuestionParams(
          question: 'Question',
          portfolioContext: 'Context',
        ),
        result: const Left(UnknownLocalAssistantFailure()),
      );
      return bloc;
    },
    seed: () => const LocalAssistantState(
      status: LocalAssistantReady(),
      portfolioContext: 'Context',
      isLoadingContext: false,
    ),
    act: (bloc) =>
        bloc.add(const SendLocalAssistantQuestionClickEvent('Question')),
    expect: () => [
      const LocalAssistantState(
        status: LocalAssistantReady(),
        portfolioContext: 'Context',
        isLoadingContext: false,
        isSendingQuestion: true,
        messages: [
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: 'Question'),
            isUser: true,
          ),
        ],
      ),
      const LocalAssistantState(
        status: LocalAssistantReady(),
        portfolioContext: 'Context',
        isLoadingContext: false,
        hasError: true,
        failure: UnknownLocalAssistantFailure(),
      ),
    ],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should expose a kept model when initialized and it is downloaded',
    build: () {
      final bloc = createBloc();
      when(() => isDownloaded()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const LocalAssistantInitializedEvent()),
    expect: () => [const LocalAssistantState(isModelDownloaded: true)],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should stay off and not download when initialized and the feature flag is off',
    build: () {
      final bloc = createBloc();
      isFeatureEnabled.stubCall(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        result: const Right(false),
      );
      when(() => getEnabled()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const LocalAssistantInitializedEvent()),
    expect: () => [
      const LocalAssistantState(
        status: LocalAssistantUnavailable(),
        isLoadingContext: false,
      ),
    ],
    verify: (_) => verifyNever(() => prepare(any())),
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should pick up the feature flag when initialized again after it was turned on',
    build: () {
      final bloc = createBloc();
      isFeatureEnabled.stubCall(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        result: const Right(false),
      );
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const LocalAssistantInitializedEvent());
      await Future<void>.delayed(Duration.zero);
      isFeatureEnabled.stubCall(
        definition: LocalAssistantFeatureFlags.aiAssistant,
        result: const Right(true),
      );
      bloc.add(const LocalAssistantInitializedEvent());
    },
    expect: () => [
      const LocalAssistantState(
        status: LocalAssistantUnavailable(),
        isLoadingContext: false,
      ),
      const LocalAssistantState(isLoadingContext: false),
    ],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should not download when initialized and the assistant is disabled',
    build: createBloc,
    act: (bloc) => bloc.add(const LocalAssistantInitializedEvent()),
    expect: () => [const LocalAssistantState()],
    verify: (_) => verifyNever(() => prepare(any())),
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should prepare the model when initialized and the assistant is enabled',
    build: () {
      final bloc = createBloc();
      when(() => getEnabled()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const LocalAssistantInitializedEvent()),
    expect: () => [
      const LocalAssistantState(),
      const LocalAssistantState(status: LocalAssistantDownloading()),
      const LocalAssistantState(status: LocalAssistantReady()),
    ],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should be ready without loading the model when it is already downloaded',
    build: () {
      final bloc = createBloc();
      when(() => getEnabled()).thenAnswer((_) => const Right(true));
      when(() => isDownloaded()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const LocalAssistantInitializedEvent()),
    expect: () => [
      const LocalAssistantState(isModelDownloaded: true),
      const LocalAssistantState(
        status: LocalAssistantReady(),
        isModelDownloaded: true,
      ),
    ],
    verify: (_) => verifyNever(() => prepare(any())),
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should persist the choice and download when enabled',
    build: createBloc,
    act: (bloc) => bloc.add(const EnableLocalAssistantClickEvent()),
    expect: () => [
      const LocalAssistantState(status: LocalAssistantDownloading()),
      const LocalAssistantState(status: LocalAssistantReady()),
    ],
    verify: (_) => verify(() => updateEnabled(true)).called(1),
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should fail when enabled and the model cannot be prepared',
    build: () {
      final bloc = createBloc();
      when(
        () => prepare(any()),
      ).thenAnswer((_) => const Left(UnknownLocalAssistantFailure()));
      return bloc;
    },
    act: (bloc) => bloc.add(const EnableLocalAssistantClickEvent()),
    expect: () => [
      const LocalAssistantState(status: LocalAssistantDownloading()),
      const LocalAssistantState(
        status: LocalAssistantFailed(),
        failure: UnknownLocalAssistantFailure(),
      ),
    ],
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should delete the model when disabled with deletion confirmed',
    build: createBloc,
    seed: () => const LocalAssistantState(status: LocalAssistantReady()),
    act: (bloc) =>
        bloc.add(const DisableLocalAssistantClickEvent(deleteModel: true)),
    expect: () => [const LocalAssistantState()],
    verify: (_) {
      verify(() => updateEnabled(false)).called(1);
      verify(() => delete()).called(1);
    },
  );

  blocTest<LocalAssistantBloc, LocalAssistantState>(
    'should keep the model when disabled without deletion',
    build: createBloc,
    seed: () => const LocalAssistantState(status: LocalAssistantReady()),
    act: (bloc) =>
        bloc.add(const DisableLocalAssistantClickEvent(deleteModel: false)),
    verify: (_) {
      verify(() => updateEnabled(false)).called(1);
      verifyNever(() => delete());
      verifyNever(() => cancel());
    },
  );

  test(
    'should cancel and discard the download when disabled while preparing',
    () async {
      final bloc = createBloc();
      addTearDown(bloc.close);
      final download = Completer<Either<LocalAssistantFailure, void>>();
      when(() => prepare(any())).thenAnswer((_) => download.future);
      bloc.add(const EnableLocalAssistantClickEvent());
      await pumpEventQueue();
      expect(bloc.state.isDownloading, isTrue);

      bloc.add(const DisableLocalAssistantClickEvent(deleteModel: false));
      await pumpEventQueue();
      download.complete(const Left(UnknownLocalAssistantFailure()));
      await pumpEventQueue();

      verify(() => cancel()).called(1);
      verifyNever(() => delete());
      expect(bloc.state.isEnabled, isFalse);
      expect(bloc.state.hasError, isFalse);
    },
  );
}
