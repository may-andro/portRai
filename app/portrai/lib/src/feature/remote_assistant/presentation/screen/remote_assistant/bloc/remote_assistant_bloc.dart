import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_event.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_state.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/tracking/_tracking.dart';

@RegisterSingleton(disposeMethodName: 'close')
class RemoteAssistantBloc
    extends Bloc<RemoteAssistantEvent, RemoteAssistantState> {
  RemoteAssistantBloc(
    this._getContext,
    this._getPreference,
    this._updatePreference,
    this._resetSession,
    this._askQuestion,
    this._isFeatureEnabled,
    this._tracking,
  ) : super(const RemoteAssistantState()) {
    on<RemoteAssistantStartedEvent>(_onStarted);
    on<AcceptRemoteAssistantConsentClickEvent>(_onAcceptConsent);
    on<DisableRemoteAssistantClickEvent>(_onDisable);
    on<ResetRemoteAssistantClickEvent>(_onReset);
    on<SendRemoteAssistantQuestionClickEvent>(_onSend);
  }

  final GetAssistantContextUseCase _getContext;
  final GetRemoteAssistantPreferenceUseCase _getPreference;
  final UpdateRemoteAssistantPreferenceUseCase _updatePreference;
  final ResetRemoteAssistantSessionUseCase _resetSession;
  final AskRemotePortfolioQuestionUseCase _askQuestion;
  final IsFeatureEnabledUseCase _isFeatureEnabled;
  final RemoteAssistantTrackingDelegate _tracking;
  int _controlRevision = 0;
  int _requestRevision = 0;

  Future<bool> _checkFlag(
    Emitter<RemoteAssistantState> emit,
    int controlRevision,
  ) async {
    final result = await _isFeatureEnabled(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    if (emit.isDone || controlRevision != _controlRevision) return false;
    if (result.isRight && result.right) return true;
    _requestRevision++;
    emit(
      state.copyWith(
        status: RemoteAssistantStatus.unavailable,
        messages: const [],
        partialAnswer: '',
        isSendingQuestion: false,
        isLoadingContext: false,
        clearContext: true,
        failure: result.isLeft ? result.left : null,
        clearFailure: result.isRight,
      ),
    );
    final reset = await _resetSession();
    if (!emit.isDone && controlRevision == _controlRevision && reset.isLeft) {
      emit(state.copyWith(failure: reset.left));
    }
    return false;
  }

  Future<void> _onStarted(
    RemoteAssistantStartedEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    if (state.isUpdatingPreference) return;
    final revision = ++_controlRevision;
    _tracking.trackScreenView();
    if (!await _checkFlag(emit, revision) || revision != _controlRevision) {
      return;
    }
    final preference = await _getPreference();
    if (emit.isDone || revision != _controlRevision) return;
    if (preference.isLeft) {
      _requestRevision++;
      emit(
        state.copyWith(
          status: RemoteAssistantStatus.off,
          messages: const [],
          partialAnswer: '',
          isSendingQuestion: false,
          isLoadingContext: false,
          clearContext: true,
          failure: preference.left,
        ),
      );
      await _resetSession();
      return;
    }
    if (!preference.right.enabled || !preference.right.consentAccepted) {
      _requestRevision++;
      emit(
        state.copyWith(
          status: RemoteAssistantStatus.off,
          messages: const [],
          partialAnswer: '',
          isSendingQuestion: false,
          clearContext: true,
          clearFailure: true,
        ),
      );
      final reset = await _resetSession();
      if (!emit.isDone && revision == _controlRevision && reset.isLeft) {
        emit(state.copyWith(failure: reset.left));
      }
      return;
    }
    emit(state.copyWith(status: RemoteAssistantStatus.ready));
    if (state.portfolioContext == null) await _loadContext(emit, revision);
  }

  Future<void> _loadContext(
    Emitter<RemoteAssistantState> emit,
    int revision,
  ) async {
    emit(state.copyWith(isLoadingContext: true, clearFailure: true));
    final result = await _getContext();
    if (emit.isDone || revision != _controlRevision || !state.isReady) return;
    emit(
      result.fold(
        (failure) => state.copyWith(isLoadingContext: false, failure: failure),
        (context) => state.copyWith(
          portfolioContext: context,
          isLoadingContext: false,
          clearFailure: true,
        ),
      ),
    );
  }

  Future<void> _onAcceptConsent(
    AcceptRemoteAssistantConsentClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    if (state.isUpdatingPreference || state.isReady) return;
    final revision = ++_controlRevision;
    emit(state.copyWith(isUpdatingPreference: true, clearFailure: true));
    if (!await _checkFlag(emit, revision) || revision != _controlRevision) {
      if (!emit.isDone && revision == _controlRevision) {
        emit(state.copyWith(isUpdatingPreference: false));
      }
      return;
    }
    final result = await _updatePreference(
      const RemoteAssistantPreferenceEntity(
        enabled: true,
        consentAccepted: true,
      ),
    );
    if (emit.isDone || revision != _controlRevision) return;
    if (result.isLeft) {
      emit(
        state.copyWith(
          status: RemoteAssistantStatus.off,
          isUpdatingPreference: false,
          failure: result.left,
        ),
      );
      return;
    }
    _tracking.trackConsentAcceptance();
    emit(
      state.copyWith(
        status: RemoteAssistantStatus.ready,
        isUpdatingPreference: false,
        clearFailure: true,
      ),
    );
    await _loadContext(emit, revision);
  }

  Future<void> _onDisable(
    DisableRemoteAssistantClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    final revision = ++_controlRevision;
    _requestRevision++;
    _tracking.trackDisable();
    emit(
      state.copyWith(
        status: RemoteAssistantStatus.off,
        messages: const [],
        partialAnswer: '',
        isSendingQuestion: false,
        isLoadingContext: false,
        isUpdatingPreference: true,
        clearContext: true,
        clearFailure: true,
      ),
    );
    final result = await _updatePreference(
      const RemoteAssistantPreferenceEntity(
        enabled: false,
        consentAccepted: false,
      ),
    );
    if (emit.isDone || revision != _controlRevision) return;
    emit(
      state.copyWith(
        isUpdatingPreference: false,
        failure: result.isLeft ? result.left : null,
        clearFailure: result.isRight,
      ),
    );
  }

  Future<void> _onReset(
    ResetRemoteAssistantClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    final revision = ++_requestRevision;
    _tracking.trackReset();
    emit(
      state.copyWith(
        messages: const [],
        partialAnswer: '',
        isSendingQuestion: false,
        clearFailure: true,
      ),
    );
    final result = await _resetSession();
    if (!emit.isDone && revision == _requestRevision && result.isLeft) {
      emit(state.copyWith(failure: result.left));
    }
  }

  Future<void> _onSend(
    SendRemoteAssistantQuestionClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    if (!state.isReady ||
        state.isSendingQuestion ||
        state.isUpdatingPreference ||
        state.portfolioContext == null) {
      return;
    }
    // Reserve the request before any await so repeated clicks cannot race.
    final revision = ++_requestRevision;
    final controlRevision = _controlRevision;
    final history = List<AssistantMessageEntity>.unmodifiable(state.messages);
    final question = event.question.trim();
    emit(state.copyWith(isSendingQuestion: true, clearFailure: true));
    if (!await _checkFlag(emit, controlRevision) ||
        emit.isDone ||
        revision != _requestRevision ||
        controlRevision != _controlRevision) {
      if (!emit.isDone && revision == _requestRevision) {
        emit(state.copyWith(isSendingQuestion: false));
      }
      return;
    }
    _tracking.trackQuestionSubmission();
    final messages = [
      ...history,
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: question),
        isUser: true,
      ),
    ];
    emit(state.copyWith(messages: messages, partialAnswer: ''));
    final result = await _askQuestion(
      AskRemotePortfolioQuestionParams(
        question: question,
        portfolioContext: state.portfolioContext!,
        history: history.length <= RemoteAssistantLimits.maxHistoryMessages
            ? history
            : history.sublist(
                history.length - RemoteAssistantLimits.maxHistoryMessages,
              ),
        onDelta: (delta) {
          if (emit.isDone || revision != _requestRevision || !state.isReady) {
            return;
          }
          emit(state.copyWith(partialAnswer: state.partialAnswer + delta));
        },
      ),
    );
    if (emit.isDone || revision != _requestRevision || !state.isReady) return;
    if (result.isLeft) {
      // Failed user turns and partial answers never enter provider history.
      emit(
        state.copyWith(
          messages: history,
          partialAnswer: '',
          isSendingQuestion: false,
          failure: result.left,
        ),
      );
      return;
    }
    emit(
      state.copyWith(
        messages: [
          ...messages,
          AssistantMessageEntity(
            content: AssistantTextResponseEntity(text: state.partialAnswer),
            isUser: false,
          ),
        ],
        partialAnswer: '',
        isSendingQuestion: false,
        clearFailure: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    _controlRevision++;
    _requestRevision++;
    await _resetSession();
    await super.close();
  }
}
