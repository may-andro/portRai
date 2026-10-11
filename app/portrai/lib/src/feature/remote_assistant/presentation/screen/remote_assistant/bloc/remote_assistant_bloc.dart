import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_event.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_state.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/tracking/_tracking.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant_availability.dart';

@RegisterSingleton(disposeMethodName: 'close')
class RemoteAssistantBloc
    extends Bloc<RemoteAssistantEvent, RemoteAssistantState> {
  RemoteAssistantBloc(
    this._getAssistantContextUseCase,
    this._resetRemoteAssistantSessionUseCase,
    this._askRemotePortfolioQuestionUseCase,
    this._isFeatureEnabledUseCase,
    this._trackingDelegate, {
    this._availability = const RemoteAssistantAvailability(),
  }) : super(const RemoteAssistantState()) {
    on<RemoteAssistantStartedEvent>(_mapRemoteAssistantStartedEventToState);
    on<RemoteAssistantInitializedEvent>(
      _mapRemoteAssistantInitializedEventToState,
    );
    on<ResetRemoteAssistantClickEvent>(
      _mapResetRemoteAssistantClickEventToState,
    );
    on<SendRemoteAssistantQuestionClickEvent>(
      _mapSendRemoteAssistantQuestionClickEventToState,
    );
  }

  final GetAssistantContextUseCase _getAssistantContextUseCase;
  final ResetRemoteAssistantSessionUseCase _resetRemoteAssistantSessionUseCase;
  final AskRemotePortfolioQuestionUseCase _askRemotePortfolioQuestionUseCase;
  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final RemoteAssistantTrackingDelegate _trackingDelegate;
  final RemoteAssistantAvailability _availability;
  int _controlRevision = 0;
  int _requestRevision = 0;
  bool get isPlatformSupported => _availability.isSupported;

  Future<bool> _checkFlag(
    Emitter<RemoteAssistantState> emit,
    int controlRevision,
  ) async {
    final result = await _isFeatureEnabledUseCase(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    if (emit.isDone || controlRevision != _controlRevision) return false;
    emit(state.copyWith(isFeatureEnabled: result.isRight && result.right));
    if (result.isRight && result.right && _availability.isSupported) {
      return true;
    }
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
    final reset = await _resetRemoteAssistantSessionUseCase();
    if (!emit.isDone && controlRevision == _controlRevision && reset.isLeft) {
      emit(state.copyWith(failure: reset.left));
    }
    return false;
  }

  Future<void> _mapRemoteAssistantStartedEventToState(
    RemoteAssistantStartedEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await _refresh(emit);
  }

  Future<void> _mapRemoteAssistantInitializedEventToState(
    RemoteAssistantInitializedEvent event,
    Emitter<RemoteAssistantState> emit,
  ) => _refresh(emit);

  Future<void> _refresh(Emitter<RemoteAssistantState> emit) async {
    final revision = ++_controlRevision;
    if (!await _checkFlag(emit, revision) || revision != _controlRevision) {
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
    final result = await _getAssistantContextUseCase();
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

  Future<void> _mapResetRemoteAssistantClickEventToState(
    ResetRemoteAssistantClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    final revision = ++_requestRevision;
    _trackingDelegate.trackReset();
    emit(
      state.copyWith(
        messages: const [],
        partialAnswer: '',
        isSendingQuestion: false,
        clearFailure: true,
      ),
    );
    final result = await _resetRemoteAssistantSessionUseCase();
    if (!emit.isDone && revision == _requestRevision && result.isLeft) {
      emit(state.copyWith(failure: result.left));
    }
  }

  Future<void> _mapSendRemoteAssistantQuestionClickEventToState(
    SendRemoteAssistantQuestionClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    if (!state.isReady ||
        state.isSendingQuestion ||
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
    _trackingDelegate.trackQuestionSubmission();
    final messages = [
      ...history,
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: question),
        isUser: true,
      ),
    ];
    emit(state.copyWith(messages: messages, partialAnswer: ''));
    final result = await _askRemotePortfolioQuestionUseCase(
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
    await _resetRemoteAssistantSessionUseCase();
    await super.close();
  }
}
