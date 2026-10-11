import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/local_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_event.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/local_assistant_state.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/tracking/_tracking.dart';

// One shared instance: Settings, the portfolio button and the assistant
// screen all reflect the same download and enabled state.
@registerSingleton
class LocalAssistantBloc
    extends Bloc<LocalAssistantEvent, LocalAssistantState> {
  LocalAssistantBloc(
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
  ) : super(const LocalAssistantState()) {
    on<LocalAssistantStartedEvent>(_onStarted);
    on<LocalAssistantInitializedEvent>(_onInitialized);
    on<EnableLocalAssistantClickEvent>(_onEnable);
    on<DisableLocalAssistantClickEvent>(_onDisable);
    on<SendLocalAssistantQuestionClickEvent>(_onSendQuestion);
  }

  final GetAssistantContextUseCase _getAssistantContextUseCase;
  final PrepareLocalAssistantModelUseCase _prepareAssistantModelUseCase;
  final GetLocalAssistantEnabledUseCase _getAssistantEnabledUseCase;
  final UpdateLocalAssistantEnabledUseCase _updateAssistantEnabledUseCase;
  final CancelLocalAssistantPreparationUseCase
  _cancelAssistantPreparationUseCase;
  final DeleteLocalAssistantModelUseCase _deleteAssistantModelUseCase;
  final IsLocalAssistantModelDownloadedUseCase
  _isAssistantModelDownloadedUseCase;
  final AskLocalPortfolioQuestionUseCase _askPortfolioQuestionUseCase;
  final LocalAssistantTrackingDelegate _trackingDelegate;
  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;

  Future<void> _onStarted(
    LocalAssistantStartedEvent event,
    Emitter<LocalAssistantState> emit,
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
    LocalAssistantInitializedEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    final flagResult = await _isFeatureEnabledUseCase(
      LocalAssistantFeatureFlags.aiAssistant,
    );
    final isFeatureEnabled = flagResult.isRight
        ? flagResult.right
        : LocalAssistantFeatureFlags.aiAssistant.defaultValue;
    if (!isFeatureEnabled) {
      emit(state.copyWith(status: const LocalAssistantUnavailable()));
      return;
    }
    if (state.status is LocalAssistantUnavailable) {
      emit(state.copyWith(status: const LocalAssistantOff()));
    }
    if (_hasInitialized) return;
    _hasInitialized = true;
    await _refreshDownloaded(emit);
    final result = await _getAssistantEnabledUseCase();
    if (result.isLeft || !result.right) return;
    // An installed model is only loaded into memory by the first question.
    if (state.isModelDownloaded) {
      emit(state.copyWith(status: const LocalAssistantReady()));
      return;
    }
    await _prepareModel(emit);
  }

  Future<void> _onEnable(
    EnableLocalAssistantClickEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    if (state.isDownloading) return;
    emit(
      state.copyWith(
        status: const LocalAssistantDownloading(),
        hasError: false,
      ),
    );
    await _updateAssistantEnabledUseCase(true);
    await _prepareModel(emit);
  }

  Future<void> _onDisable(
    DisableLocalAssistantClickEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    final wasDownloading = state.isDownloading;
    emit(
      state.copyWith(
        status: const LocalAssistantOff(),
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

  Future<void> _refreshDownloaded(Emitter<LocalAssistantState> emit) async {
    final result = await _isAssistantModelDownloadedUseCase();
    emit(state.copyWith(isModelDownloaded: result.isRight && result.right));
  }

  Future<void> _prepareModel(Emitter<LocalAssistantState> emit) async {
    emit(
      state.copyWith(
        status: const LocalAssistantDownloading(),
        hasError: false,
      ),
    );
    final result = await _prepareAssistantModelUseCase((progress) {
      if (state.isDownloading) {
        emit(state.copyWith(status: LocalAssistantDownloading(progress)));
      }
    });
    await _refreshDownloaded(emit);
    // Turning the assistant off meanwhile leaves it off, so a failure then is
    // a cancellation and a success is discarded.
    if (!state.isDownloading) return;
    emit(
      state.copyWith(
        status: result.isRight
            ? const LocalAssistantReady()
            : const LocalAssistantFailed(),
      ),
    );
  }

  Future<void> _onSendQuestion(
    SendLocalAssistantQuestionClickEvent event,
    Emitter<LocalAssistantState> emit,
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
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: question),
        isUser: true,
      ),
    ];
    emit(
      state.copyWith(
        messages: messages,
        isSendingQuestion: true,
        hasError: false,
      ),
    );

    final result = await _askPortfolioQuestionUseCase(
      AskLocalPortfolioQuestionParams(
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
            AssistantMessageEntity(content: answer, isUser: false),
          ],
          isSendingQuestion: false,
          hasError: false,
        ),
      ),
    );
  }
}
