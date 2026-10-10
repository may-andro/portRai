import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_event.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_state.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/tracking/_tracking.dart';

// One shared instance: Settings, the portfolio button and the assistant
// screen all reflect the same download and enabled state.
@registerSingleton
class AssistantBloc extends Bloc<AssistantEvent, AssistantState> {
  AssistantBloc(
    this._getAssistantContextUseCase,
    this._prepareAssistantModelUseCase,
    this._getAssistantEnabledUseCase,
    this._updateAssistantEnabledUseCase,
    this._cancelAssistantPreparationUseCase,
    this._deleteAssistantModelUseCase,
    this._isAssistantModelDownloadedUseCase,
    this._askPortfolioQuestionUseCase,
    this._trackingDelegate,
    this._isFeatureEnabledUseCase,
  ) : super(const AssistantState()) {
    on<AssistantStartedEvent>(_onStarted);
    on<AssistantInitializedEvent>(_onInitialized);
    on<EnableAssistantClickEvent>(_onEnable);
    on<DisableAssistantClickEvent>(_onDisable);
    on<SendAssistantQuestionClickEvent>(_onSendQuestion);
  }

  final GetAssistantContextUseCase _getAssistantContextUseCase;
  final PrepareAssistantModelUseCase _prepareAssistantModelUseCase;
  final GetAssistantEnabledUseCase _getAssistantEnabledUseCase;
  final UpdateAssistantEnabledUseCase _updateAssistantEnabledUseCase;
  final CancelAssistantPreparationUseCase _cancelAssistantPreparationUseCase;
  final DeleteAssistantModelUseCase _deleteAssistantModelUseCase;
  final IsAssistantModelDownloadedUseCase _isAssistantModelDownloadedUseCase;
  final AskPortfolioQuestionUseCase _askPortfolioQuestionUseCase;
  final AssistantTrackingDelegate _trackingDelegate;
  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;

  Future<void> _onStarted(
    AssistantStartedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    final result = await _getAssistantContextUseCase();
    result.fold(
      (_) => emit(state.copyWith(isLoadingContext: false, hasError: true)),
      (context) => emit(
        state.copyWith(
          portfolioContext: context,
          isLoadingContext: false,
          hasError: false,
        ),
      ),
    );
  }

  Future<void> _onInitialized(
    AssistantInitializedEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final flagResult = await _isFeatureEnabledUseCase(
      AssistantFeatureFlags.aiAssistant,
    );
    final isFeatureEnabled = flagResult.isRight
        ? flagResult.right
        : AssistantFeatureFlags.aiAssistant.defaultValue;
    if (!isFeatureEnabled) {
      emit(state.copyWith(isFeatureEnabled: false));
      return;
    }
    await _refreshDownloaded(emit);
    final result = await _getAssistantEnabledUseCase();
    if (result.isLeft || !result.right) return;
    emit(state.copyWith(isEnabled: true));
    await _prepareModel(emit);
  }

  Future<void> _onEnable(
    EnableAssistantClickEvent event,
    Emitter<AssistantState> emit,
  ) async {
    emit(state.copyWith(isEnabled: true, hasError: false));
    await _updateAssistantEnabledUseCase(true);
    await _prepareModel(emit);
  }

  Future<void> _onDisable(
    DisableAssistantClickEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final wasPreparing = state.isPreparingModel;
    emit(state.copyWith(isEnabled: false, hasError: false, messages: const []));
    await _updateAssistantEnabledUseCase(false);
    // A download that is still running is always discarded.
    if (wasPreparing) {
      await _cancelAssistantPreparationUseCase();
    } else if (event.deleteModel) {
      await _deleteAssistantModelUseCase();
    }
    emit(
      state.copyWith(
        isPreparingModel: false,
        isModelReady: false,
        downloadProgress: 0,
      ),
    );
    await _refreshDownloaded(emit);
  }

  Future<void> _refreshDownloaded(Emitter<AssistantState> emit) async {
    final result = await _isAssistantModelDownloadedUseCase();
    emit(state.copyWith(isModelDownloaded: result.isRight && result.right));
  }

  Future<void> _prepareModel(Emitter<AssistantState> emit) async {
    if (state.isPreparingModel) return;
    emit(
      state.copyWith(
        isPreparingModel: true,
        downloadProgress: 0,
        hasError: false,
      ),
    );
    final result = await _prepareAssistantModelUseCase((progress) {
      if (state.isEnabled) emit(state.copyWith(downloadProgress: progress));
    });
    await _refreshDownloaded(emit);
    result.fold(
      // A failure after the user turned the assistant off is a cancellation.
      (_) => emit(
        state.copyWith(isPreparingModel: false, hasError: state.isEnabled),
      ),
      (_) => emit(
        state.copyWith(
          isPreparingModel: false,
          isModelReady: state.isEnabled,
          hasError: false,
        ),
      ),
    );
  }

  Future<void> _onSendQuestion(
    SendAssistantQuestionClickEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final question = event.question.trim();
    final portfolioContext = state.portfolioContext;
    if (question.isEmpty ||
        portfolioContext == null ||
        !state.isModelReady ||
        state.isSendingQuestion) {
      return;
    }

    _trackingDelegate.trackQuestionSubmission();
    final messages = [
      ...state.messages,
      AssistantMessage(text: question, isUser: true),
    ];
    emit(
      state.copyWith(
        messages: messages,
        isSendingQuestion: true,
        hasError: false,
      ),
    );

    final result = await _askPortfolioQuestionUseCase(
      AskPortfolioQuestionParams(
        question: question,
        portfolioContext: portfolioContext,
      ),
    );
    result.fold(
      (_) => emit(state.copyWith(isSendingQuestion: false, hasError: true)),
      (answer) => emit(
        state.copyWith(
          messages: [
            ...messages,
            AssistantMessage(text: answer, isUser: false),
          ],
          isSendingQuestion: false,
          hasError: false,
        ),
      ),
    );
  }
}
