import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/domain/feature_flag/_feature_flag.dart';
import 'package:portrai/src/feature/assistant/domain/use_case/assistant_failure.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';
import 'package:use_case/use_case.dart';

import '../../../../../../../mock/feature/assistant/domain/use_case/mock_ask_portfolio_question_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_cancel_assistant_preparation_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_delete_assistant_model_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_context_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_get_assistant_enabled_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_is_assistant_model_downloaded_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_prepare_assistant_model_use_case.dart';
import '../../../../../../../mock/feature/assistant/domain/use_case/mock_update_assistant_enabled_use_case.dart';
import '../../../../../../../mock/feature/assistant/presentation/screen/assistant/tracking/mock_assistant_tracking_delegate.dart';
import '../../../../../../../mock/feature/feature_flag/domain/use_case/mock_is_feature_enabled_use_case.dart';

void main() {
  late MockGetAssistantEnabledUseCase getEnabled;
  late MockIsAssistantModelDownloadedUseCase isDownloaded;
  late MockUpdateAssistantEnabledUseCase updateEnabled;
  late MockPrepareAssistantModelUseCase prepare;
  late MockCancelAssistantPreparationUseCase cancel;
  late MockDeleteAssistantModelUseCase delete;
  late MockIsFeatureEnabledUseCase isFeatureEnabled;

  setUpAll(() {
    registerFallbackValue((int _) {});
  });

  AssistantBloc createBloc() {
    getEnabled = MockGetAssistantEnabledUseCase();
    updateEnabled = MockUpdateAssistantEnabledUseCase();
    prepare = MockPrepareAssistantModelUseCase();
    cancel = MockCancelAssistantPreparationUseCase();
    delete = MockDeleteAssistantModelUseCase();
    when(() => getEnabled()).thenAnswer((_) => const Right(false));
    when(() => updateEnabled(any())).thenAnswer((_) => const Right(null));
    when(() => prepare(any())).thenAnswer((_) => const Right(null));
    when(() => cancel()).thenAnswer((_) => const Right(null));
    when(() => delete()).thenAnswer((_) => const Right(null));
    isDownloaded = MockIsAssistantModelDownloadedUseCase();
    when(() => isDownloaded()).thenAnswer((_) => const Right(false));
    isFeatureEnabled = MockIsFeatureEnabledUseCase()
      ..stubCall(
        definition: AssistantFeatureFlags.aiAssistant,
        result: const Right(true),
      );
    return AssistantBloc(
      MockGetAssistantContextUseCase(),
      prepare,
      getEnabled,
      updateEnabled,
      cancel,
      delete,
      isDownloaded,
      MockAskPortfolioQuestionUseCase(),
      MockAssistantTrackingDelegate(),
      isFeatureEnabled,
    );
  }

  blocTest<AssistantBloc, AssistantState>(
    'should expose a kept model when initialized and it is downloaded',
    build: () {
      final bloc = createBloc();
      when(() => isDownloaded()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const AssistantInitializedEvent()),
    expect: () => [
      const AssistantState(),
      const AssistantState(isModelDownloaded: true),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'should stay off and not download when initialized and the feature flag is off',
    build: () {
      final bloc = createBloc();
      isFeatureEnabled.stubCall(
        definition: AssistantFeatureFlags.aiAssistant,
        result: const Right(false),
      );
      when(() => getEnabled()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const AssistantInitializedEvent()),
    expect: () => [const AssistantState(isFeatureEnabled: false)],
    verify: (_) => verifyNever(() => prepare(any())),
  );

  blocTest<AssistantBloc, AssistantState>(
    'should pick up the feature flag when initialized again after it was turned on',
    build: () {
      final bloc = createBloc();
      isFeatureEnabled.stubCall(
        definition: AssistantFeatureFlags.aiAssistant,
        result: const Right(false),
      );
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const AssistantInitializedEvent());
      await Future<void>.delayed(Duration.zero);
      isFeatureEnabled.stubCall(
        definition: AssistantFeatureFlags.aiAssistant,
        result: const Right(true),
      );
      bloc.add(const AssistantInitializedEvent());
    },
    expect: () => [
      const AssistantState(isFeatureEnabled: false),
      const AssistantState(),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'should not download when initialized and the assistant is disabled',
    build: createBloc,
    act: (bloc) => bloc.add(const AssistantInitializedEvent()),
    expect: () => [const AssistantState()],
    verify: (_) => verifyNever(() => prepare(any())),
  );

  blocTest<AssistantBloc, AssistantState>(
    'should prepare the model when initialized and the assistant is enabled',
    build: () {
      final bloc = createBloc();
      when(() => getEnabled()).thenAnswer((_) => const Right(true));
      return bloc;
    },
    act: (bloc) => bloc.add(const AssistantInitializedEvent()),
    expect: () => [
      const AssistantState(),
      const AssistantState(isEnabled: true),
      const AssistantState(isEnabled: true, isPreparingModel: true),
      const AssistantState(isEnabled: true, isModelReady: true),
    ],
  );

  blocTest<AssistantBloc, AssistantState>(
    'should persist the choice and download when enabled',
    build: createBloc,
    act: (bloc) => bloc.add(const EnableAssistantClickEvent()),
    expect: () => [
      const AssistantState(isEnabled: true),
      const AssistantState(isEnabled: true, isPreparingModel: true),
      const AssistantState(isEnabled: true, isModelReady: true),
    ],
    verify: (_) => verify(() => updateEnabled(true)).called(1),
  );

  blocTest<AssistantBloc, AssistantState>(
    'should delete the model when disabled with deletion confirmed',
    build: createBloc,
    seed: () => const AssistantState(isEnabled: true, isModelReady: true),
    act: (bloc) =>
        bloc.add(const DisableAssistantClickEvent(deleteModel: true)),
    expect: () => [
      const AssistantState(isModelReady: true),
      const AssistantState(),
    ],
    verify: (_) {
      verify(() => updateEnabled(false)).called(1);
      verify(() => delete()).called(1);
    },
  );

  blocTest<AssistantBloc, AssistantState>(
    'should keep the model when disabled without deletion',
    build: createBloc,
    seed: () => const AssistantState(isEnabled: true, isModelReady: true),
    act: (bloc) =>
        bloc.add(const DisableAssistantClickEvent(deleteModel: false)),
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
      final download = Completer<Either<AssistantFailure, void>>();
      when(() => prepare(any())).thenAnswer((_) => download.future);
      bloc.add(const EnableAssistantClickEvent());
      await pumpEventQueue();
      expect(bloc.state.isPreparingModel, isTrue);

      bloc.add(const DisableAssistantClickEvent(deleteModel: false));
      await pumpEventQueue();
      download.complete(const Left(UnknownAssistantFailure()));
      await pumpEventQueue();

      verify(() => cancel()).called(1);
      verifyNever(() => delete());
      expect(bloc.state.isEnabled, isFalse);
      expect(bloc.state.isPreparingModel, isFalse);
      expect(bloc.state.hasError, isFalse);
    },
  );
}
