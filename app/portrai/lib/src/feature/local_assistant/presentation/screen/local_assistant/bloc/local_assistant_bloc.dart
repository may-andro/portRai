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
@RegisterSingleton(disposeMethodName: 'close')
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
    this._isFeatureEnabledUseCase, {
    required this._isLocalAssistantSupportedUseCase,
    @Inject(ResetLocalAssistantSessionUseCase)
    required this._resetLocalAssistantSessionUseCase,
  }) : super(const LocalAssistantState()) {
    on<LocalAssistantStartedEvent>(_mapLocalAssistantStartedEventToState);
    on<LocalAssistantInitializedEvent>(
      _mapLocalAssistantInitializedEventToState,
    );
    on<EnableLocalAssistantClickEvent>(
      _mapEnableLocalAssistantClickEventToState,
    );
    on<DisableLocalAssistantClickEvent>(
      _mapDisableLocalAssistantClickEventToState,
    );
    on<SendLocalAssistantQuestionClickEvent>(
      _mapSendLocalAssistantQuestionClickEventToState,
    );
    on<ResetLocalAssistantClickEvent>(_mapResetLocalAssistantClickEventToState);
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
  final IsLocalAssistantSupportedUseCase _isLocalAssistantSupportedUseCase;
  final ResetLocalAssistantSessionUseCase _resetLocalAssistantSessionUseCase;
  int _controlRevision = 0;
  int _requestRevision = 0;

  Future<bool> _checkAvailability(Emitter<LocalAssistantState> emit) async {
    final revision = _controlRevision;
    final result = await _isFeatureEnabledUseCase(
      LocalAssistantFeatureFlags.aiAssistant,
    );
    if (emit.isDone || revision != _controlRevision) return false;
    final support = await _isLocalAssistantSupportedUseCase();
    if (emit.isDone || revision != _controlRevision) return false;
    if (result.isRight && result.right && support.isRight && support.right) {
      return true;
    }
    _controlRevision++;
    _requestRevision++;
    final invalidationRevision = _controlRevision;
    _hasInitialized = false;
    final wasDownloading = state.isDownloading;
    emit(
      state.copyWith(
        status: const LocalAssistantUnavailable(),
        messages: const [],
        isSendingQuestion: false,
        partialAnswer: '',
        isLoadingContext: false,
        clearContext: true,
        hasError: result.isLeft || support.isLeft,
        failure: result.isLeft
            ? result.left
            : support.isLeft
            ? support.left
            : null,
        clearFailure: result.isRight && support.isRight,
      ),
    );
    final reset = await _resetLocalAssistantSessionUseCase();
    if (emit.isDone || invalidationRevision != _controlRevision) return false;
    if (reset.isLeft) {
      emit(state.copyWith(hasError: true, failure: reset.left));
    }
    if (wasDownloading) {
      final result = await _cancelAssistantPreparationUseCase();
      if (!emit.isDone &&
          invalidationRevision == _controlRevision &&
          result.isLeft) {
        emit(state.copyWith(hasError: true, failure: result.left));
      }
    }
    return false;
  }

  Future<void> _mapLocalAssistantStartedEventToState(
    LocalAssistantStartedEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    if (!await _checkAvailability(emit)) return;
    final revision = _controlRevision;
    await _initialize(emit, revision);
    if (emit.isDone || revision != _controlRevision) return;
    emit(state.copyWith(isLoadingContext: true));
    final result = await _getAssistantContextUseCase();
    if (emit.isDone || revision != _controlRevision) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoadingContext: false,
          hasError: true,
          failure: failure,
        ),
      ),
      (context) => emit(
        state.copyWith(
          portfolioContext: context,
          isLoadingContext: false,
          hasError: false,
          clearFailure: true,
        ),
      ),
    );
  }

  var _hasInitialized = false;

  // Dispatched again when screens become visible, so a flag turned on at
  // runtime (dev menu) is picked up. Setup only ever runs once.
  Future<void> _mapLocalAssistantInitializedEventToState(
    LocalAssistantInitializedEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    if (!await _checkAvailability(emit)) return;
    final revision = _controlRevision;
    await _initialize(emit, revision);
  }

  Future<void> _initialize(
    Emitter<LocalAssistantState> emit,
    int revision,
  ) async {
    if (state.status is LocalAssistantUnavailable) {
      emit(state.copyWith(status: const LocalAssistantOff()));
    }
    if (_hasInitialized) return;
    _hasInitialized = true;
    if (!await _refreshDownloaded(emit, revision)) {
      _hasInitialized = false;
      return;
    }
    final result = await _getAssistantEnabledUseCase();
    if (emit.isDone || revision != _controlRevision) return;
    if (result.isLeft) {
      emit(state.copyWith(hasError: true, failure: result.left));
      return;
    }
    if (!result.right) return;
    // An installed model is only loaded into memory by the first question.
    if (state.isModelDownloaded) {
      emit(state.copyWith(status: const LocalAssistantReady()));
      return;
    }
    await _prepareModel(emit, revision);
  }

  Future<void> _mapEnableLocalAssistantClickEventToState(
    EnableLocalAssistantClickEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    if (state.isDownloading) return;
    final revision = ++_controlRevision;
    emit(
      state.copyWith(
        status: const LocalAssistantDownloading(),
        hasError: false,
        clearFailure: true,
      ),
    );
    if (!await _checkAvailability(emit) || revision != _controlRevision) return;
    final result = await _updateAssistantEnabledUseCase(true);
    if (emit.isDone || revision != _controlRevision) return;
    if (result.isLeft) {
      emit(
        state.copyWith(
          status: const LocalAssistantFailed(),
          hasError: true,
          failure: result.left,
        ),
      );
      return;
    }
    await _prepareModel(emit, revision);
  }

  Future<void> _mapDisableLocalAssistantClickEventToState(
    DisableLocalAssistantClickEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    final wasDownloading = state.isDownloading;
    final revision = ++_controlRevision;
    _requestRevision++;
    emit(
      state.copyWith(
        status: const LocalAssistantOff(),
        hasError: false,
        messages: const [],
        isSendingQuestion: false,
        partialAnswer: '',
        clearFailure: true,
      ),
    );
    final result = await _updateAssistantEnabledUseCase(false);
    if (emit.isDone || revision != _controlRevision) return;
    if (result.isLeft) {
      emit(state.copyWith(hasError: true, failure: result.left));
    }
    // A download that is still running is always discarded.
    if (wasDownloading) {
      final cancelled = await _cancelAssistantPreparationUseCase();
      if (!emit.isDone && revision == _controlRevision && cancelled.isLeft) {
        emit(state.copyWith(hasError: true, failure: cancelled.left));
      }
    } else if (event.deleteModel) {
      final deleted = await _deleteAssistantModelUseCase();
      if (!emit.isDone && revision == _controlRevision && deleted.isLeft) {
        emit(state.copyWith(hasError: true, failure: deleted.left));
      }
    }
    await _refreshDownloaded(emit, revision);
  }

  Future<bool> _refreshDownloaded(
    Emitter<LocalAssistantState> emit,
    int revision,
  ) async {
    final result = await _isAssistantModelDownloadedUseCase();
    if (emit.isDone || revision != _controlRevision) return false;
    if (result.isLeft) {
      emit(state.copyWith(hasError: true, failure: result.left));
      return false;
    } else {
      emit(state.copyWith(isModelDownloaded: result.right));
      return true;
    }
  }

  Future<void> _prepareModel(
    Emitter<LocalAssistantState> emit,
    int revision,
  ) async {
    emit(
      state.copyWith(
        status: const LocalAssistantDownloading(),
        hasError: false,
      ),
    );
    final result = await _prepareAssistantModelUseCase((progress) {
      if (!emit.isDone && revision == _controlRevision && state.isDownloading) {
        emit(state.copyWith(status: LocalAssistantDownloading(progress)));
      }
    });
    if (emit.isDone || revision != _controlRevision) return;
    if (!await _refreshDownloaded(emit, revision)) {
      if (!emit.isDone && revision == _controlRevision) {
        emit(state.copyWith(status: const LocalAssistantFailed()));
      }
      return;
    }
    // Turning the assistant off meanwhile leaves it off, so a failure then is
    // a cancellation and a success is discarded.
    if (emit.isDone || revision != _controlRevision || !state.isDownloading) {
      return;
    }
    emit(
      state.copyWith(
        status: result.isRight
            ? const LocalAssistantReady()
            : const LocalAssistantFailed(),
        failure: result.isLeft ? result.left : null,
        clearFailure: result.isRight,
      ),
    );
  }

  Future<void> _mapSendLocalAssistantQuestionClickEventToState(
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

    final revision = ++_requestRevision;
    final history = state.messages;
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
    if (!await _checkAvailability(emit) || revision != _requestRevision) return;
    _trackingDelegate.trackQuestionSubmission();

    final result = await _askPortfolioQuestionUseCase(
      AskLocalPortfolioQuestionParams(
        question: question,
        portfolioContext: portfolioContext,
        onPartialAnswer: (partialAnswer) {
          if (!emit.isDone && revision == _requestRevision && state.isReady) {
            emit(state.copyWith(partialAnswer: partialAnswer));
          }
        },
      ),
    );
    if (emit.isDone || revision != _requestRevision || !state.isReady) return;
    result.fold(
      (failure) => emit(
        state.copyWith(
          messages: history,
          isSendingQuestion: false,
          partialAnswer: '',
          hasError: true,
          failure: failure,
        ),
      ),
      (answer) => emit(
        state.copyWith(
          messages: [
            ...messages,
            AssistantMessageEntity(content: answer, isUser: false),
          ],
          isSendingQuestion: false,
          partialAnswer: '',
          hasError: false,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _mapResetLocalAssistantClickEventToState(
    ResetLocalAssistantClickEvent event,
    Emitter<LocalAssistantState> emit,
  ) async {
    final revision = ++_requestRevision;
    _trackingDelegate.trackReset();
    emit(
      state.copyWith(
        messages: const [],
        isSendingQuestion: false,
        partialAnswer: '',
        hasError: false,
        clearFailure: true,
      ),
    );
    final result = await _resetLocalAssistantSessionUseCase();
    if (!emit.isDone && revision == _requestRevision && result.isLeft) {
      emit(state.copyWith(hasError: true, failure: result.left));
    }
  }

  @override
  Future<void> close() async {
    _controlRevision++;
    _requestRevision++;
    await super.close();
  }
}
