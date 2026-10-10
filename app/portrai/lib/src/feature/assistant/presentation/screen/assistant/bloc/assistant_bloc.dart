import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/domain/_domain.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_event.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/assistant_state.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/tracking/_tracking.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';

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

  var _hasInitialized = false;

  // Dispatched again when screens become visible, so a flag turned on at
  // runtime (dev menu) is picked up. Setup only ever runs once.
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
      emit(state.copyWith(status: const AssistantUnavailable()));
      return;
    }
    if (state.status is AssistantUnavailable) {
      emit(state.copyWith(status: const AssistantOff()));
    }
    if (_hasInitialized) return;
    _hasInitialized = true;
    await _refreshDownloaded(emit);
    final result = await _getAssistantEnabledUseCase();
    if (result.isLeft || !result.right) return;
    await _prepareModel(emit);
  }

  Future<void> _onEnable(
    EnableAssistantClickEvent event,
    Emitter<AssistantState> emit,
  ) async {
    if (state.isDownloading) return;
    emit(state.copyWith(status: const AssistantDownloading(), hasError: false));
    await _updateAssistantEnabledUseCase(true);
    await _prepareModel(emit);
  }

  Future<void> _onDisable(
    DisableAssistantClickEvent event,
    Emitter<AssistantState> emit,
  ) async {
    final wasDownloading = state.isDownloading;
    emit(
      state.copyWith(
        status: const AssistantOff(),
        hasError: false,
        messages: const [],
      ),
    );
    await _updateAssistantEnabledUseCase(false);
    // A download that is still running is always discarded.
    if (wasDownloading) {
      await _cancelAssistantPreparationUseCase();
    } else if (event.deleteModel) {
      await _deleteAssistantModelUseCase();
    }
    await _refreshDownloaded(emit);
  }

  Future<void> _refreshDownloaded(Emitter<AssistantState> emit) async {
    final result = await _isAssistantModelDownloadedUseCase();
    emit(state.copyWith(isModelDownloaded: result.isRight && result.right));
  }

  Future<void> _prepareModel(Emitter<AssistantState> emit) async {
    emit(state.copyWith(status: const AssistantDownloading(), hasError: false));
    final result = await _prepareAssistantModelUseCase((progress) {
      if (state.isDownloading) {
        emit(state.copyWith(status: AssistantDownloading(progress)));
      }
    });
    await _refreshDownloaded(emit);
    // Turning the assistant off meanwhile leaves it off, so a failure then is
    // a cancellation and a success is discarded.
    if (!state.isDownloading) return;
    emit(
      state.copyWith(
        status: result.isRight
            ? const AssistantReady()
            : const AssistantFailed(),
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
        !state.isReady ||
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
