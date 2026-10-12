import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_event.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_state.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/tracking/_tracking.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/service/remote_assistant_genui_session_extension.dart';
import 'package:use_case/use_case.dart';

@RegisterSingleton(disposeMethodName: 'close')
class RemoteAssistantBloc
    extends Bloc<RemoteAssistantEvent, RemoteAssistantState> {
  RemoteAssistantBloc(
    this._getAssistantContextUseCase,
    this._resetRemoteAssistantSessionUseCase,
    this._askRemotePortfolioQuestionUseCase,
    this._isFeatureEnabledUseCase,
    this._isRemoteAssistantSupportedUseCase,
    this._trackingDelegate,
  ) : super(const RemoteAssistantState()) {
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
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;
  final RemoteAssistantTrackingDelegate _trackingDelegate;
  int _controlRevision = 0;
  int _requestRevision = 0;
  final Set<AssistantGenuiSession> _genuiSessions = {};
  final Map<
    AssistantGenuiSession,
    StreamSubscription<AssistantGenuiResponseException>
  >
  _genuiErrorSubscriptions = {};

  Future<bool> _checkFlag(
    Emitter<RemoteAssistantState> emit,
    int controlRevision,
  ) async {
    final result = await _isFeatureEnabledUseCase(
      RemoteAssistantFeatureFlags.remoteAssistant,
    );
    if (emit.isDone || controlRevision != _controlRevision) return false;
    emit(state.copyWith(isFeatureEnabled: result.isRight && result.right));
    final platformSupport = await _isRemoteAssistantSupportedUseCase();
    if (emit.isDone || controlRevision != _controlRevision) return false;
    if (result.isRight &&
        result.right &&
        platformSupport.isRight &&
        platformSupport.right) {
      final generativeUi = await _isFeatureEnabledUseCase(
        RemoteAssistantFeatureFlags.generativeUi,
      );
      if (emit.isDone || controlRevision != _controlRevision) return false;
      if (generativeUi.isLeft) {
        _requestRevision++;
        emit(
          state.copyWith(
            status: RemoteAssistantStatus.unavailable,
            messages: const [],
            isGenerativeUiEnabled: false,
            clearGenuiSurfaces: true,
            partialAnswer: '',
            isSendingQuestion: false,
            isLoadingContext: false,
            clearContext: true,
            failure: generativeUi.left,
          ),
        );
        _disposeGenuiSessions();
        final reset = await _resetRemoteAssistantSessionUseCase();
        if (!emit.isDone &&
            controlRevision == _controlRevision &&
            reset.isLeft) {
          emit(state.copyWith(failure: reset.left));
        }
        return false;
      }
      final isGenerativeUiEnabled = generativeUi.isRight && generativeUi.right;
      final modeChanged =
          state.isGenerativeUiEnabled != isGenerativeUiEnabled &&
          (state.messages.isNotEmpty ||
              state.genuiSurfaces.isNotEmpty ||
              state.isSendingQuestion);
      if (modeChanged) {
        _requestRevision++;
        emit(
          state.copyWith(
            isGenerativeUiEnabled: isGenerativeUiEnabled,
            messages: const [],
            clearGenuiSurfaces: true,
            partialAnswer: '',
            isSendingQuestion: false,
            failure: generativeUi.isLeft ? generativeUi.left : null,
            clearFailure: generativeUi.isRight,
          ),
        );
        _disposeGenuiSessions();
        final reset = await _resetRemoteAssistantSessionUseCase();
        if (!emit.isDone &&
            controlRevision == _controlRevision &&
            reset.isLeft) {
          emit(state.copyWith(failure: reset.left));
        }
        return false;
      }
      emit(
        state.copyWith(
          isGenerativeUiEnabled: isGenerativeUiEnabled,
          failure: generativeUi.isLeft ? generativeUi.left : null,
          clearFailure: generativeUi.isRight,
        ),
      );
      return true;
    }
    _requestRevision++;
    emit(
      state.copyWith(
        status: RemoteAssistantStatus.unavailable,
        messages: const [],
        isGenerativeUiEnabled: false,
        clearGenuiSurfaces: true,
        partialAnswer: '',
        isSendingQuestion: false,
        isLoadingContext: false,
        clearContext: true,
        failure: result.isLeft ? result.left : null,
        clearFailure: result.isRight,
      ),
    );
    _disposeGenuiSessions();
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
        clearGenuiSurfaces: true,
        partialAnswer: '',
        isSendingQuestion: false,
        clearFailure: true,
      ),
    );
    _disposeGenuiSessions();
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
    final requestHistory = state.isGenerativeUiEnabled
        ? history
              .where(
                (message) =>
                    message.content is AssistantTextResponseEntity &&
                    (message.content as AssistantTextResponseEntity)
                        .text
                        .isNotEmpty,
              )
              .toList()
        : history;
    final boundedHistory =
        requestHistory.length <= RemoteAssistantLimits.maxHistoryMessages
        ? requestHistory
        : requestHistory.sublist(
            requestHistory.length - RemoteAssistantLimits.maxHistoryMessages,
          );
    final AssistantGenuiSession? genuiSession;
    final Either<RemoteAssistantFailure, void> result;
    if (state.isGenerativeUiEnabled) {
      final session = AssistantGenuiSession();
      genuiSession = session;
      _genuiSessions.add(session);
      _genuiErrorSubscriptions[session] = session.frameworkErrors.listen(
        (_) => _handleGenuiFrameworkError(emit, session),
      );
      final surfaceMessageIndex = messages.length;
      result = await session.sendPortfolioQuestion(
        askRemotePortfolioQuestionUseCase: _askRemotePortfolioQuestionUseCase,
        question: question,
        portfolioContext: state.portfolioContext!,
        history: boundedHistory,
        onText: (text) {
          if (emit.isDone || revision != _requestRevision || !state.isReady) {
            return;
          }
          emit(state.copyWith(partialAnswer: state.partialAnswer + text));
        },
        onSurfaceUpdate: (_) {
          if (emit.isDone || revision != _requestRevision || !state.isReady) {
            return;
          }
          final currentSurfaces = state.genuiSurfaces
              .where((surface) => !identical(surface.session, session))
              .toList();
          currentSurfaces.addAll(
            session.activeSurfaceIds.map(
              (surfaceId) => RemoteAssistantSurface(
                messageIndex: surfaceMessageIndex,
                session: session,
                surfaceId: surfaceId,
              ),
            ),
          );
          emit(state.copyWith(genuiSurfaces: currentSurfaces));
        },
      );
    } else {
      genuiSession = null;
      result = await _askRemotePortfolioQuestionUseCase(
        AskRemotePortfolioQuestionParams(
          question: question,
          portfolioContext: state.portfolioContext!,
          history: boundedHistory,
          onDelta: (delta) {
            if (emit.isDone || revision != _requestRevision || !state.isReady) {
              return;
            }
            emit(state.copyWith(partialAnswer: state.partialAnswer + delta));
          },
        ),
      );
    }
    if (emit.isDone || revision != _requestRevision || !state.isReady) return;
    if (result.isLeft) {
      // Failed user turns and partial answers never enter provider history.
      emit(
        state.copyWith(
          messages: history,
          clearGenuiSurfaces: true,
          partialAnswer: '',
          isSendingQuestion: false,
          failure: result.left,
        ),
      );
      if (genuiSession != null) _retireGenuiSession(genuiSession);
      return;
    }
    var completedMessages = [
      ...messages,
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: state.partialAnswer.trim()),
        isUser: false,
      ),
    ];
    var completedSurfaces = state.genuiSurfaces;
    if (genuiSession != null && genuiSession.activeSurfaceIds.isEmpty) {
      completedSurfaces = completedSurfaces
          .where((surface) => !identical(surface.session, genuiSession))
          .toList();
      _retireGenuiSession(genuiSession);
    }
    if (state.isGenerativeUiEnabled &&
        completedMessages.length > RemoteAssistantLimits.maxHistoryMessages) {
      final removedCount =
          completedMessages.length - RemoteAssistantLimits.maxHistoryMessages;
      completedMessages = completedMessages.sublist(removedCount);
      completedSurfaces = completedSurfaces
          .where((surface) => surface.messageIndex >= removedCount)
          .map(
            (surface) => RemoteAssistantSurface(
              messageIndex: surface.messageIndex - removedCount,
              session: surface.session,
              surfaceId: surface.surfaceId,
            ),
          )
          .toList();
    }
    emit(
      state.copyWith(
        messages: completedMessages,
        genuiSurfaces: completedSurfaces,
        partialAnswer: '',
        isSendingQuestion: false,
        clearFailure: true,
      ),
    );
    _retainGenuiSessions(completedSurfaces);
  }

  void _retainGenuiSessions(Iterable<RemoteAssistantSurface> surfaces) {
    final retained = surfaces.map((surface) => surface.session).toSet();
    for (final session in _genuiSessions.toList()) {
      if (!retained.contains(session)) _retireGenuiSession(session);
    }
  }

  void _retireGenuiSession(AssistantGenuiSession session) {
    _genuiErrorSubscriptions.remove(session)?.cancel();
    if (_genuiSessions.remove(session)) session.dispose();
  }

  void _disposeGenuiSessions() {
    for (final session in _genuiSessions.toList()) {
      _retireGenuiSession(session);
    }
  }

  void _handleGenuiFrameworkError(
    Emitter<RemoteAssistantState> emit,
    AssistantGenuiSession session,
  ) {
    if (emit.isDone || !_genuiSessions.contains(session)) return;
    _requestRevision++;
    emit(
      state.copyWith(
        messages: const [],
        clearGenuiSurfaces: true,
        partialAnswer: '',
        isSendingQuestion: false,
        failure: const RemoteAssistantIncompleteFailure(),
      ),
    );
    _disposeGenuiSessions();
    unawaited(() async {
      final reset = await _resetRemoteAssistantSessionUseCase();
      if (!emit.isDone && reset.isLeft) {
        emit(state.copyWith(failure: reset.left));
      }
    }());
  }

  @override
  Future<void> close() async {
    _controlRevision++;
    _requestRevision++;
    _disposeGenuiSessions();
    await _resetRemoteAssistantSessionUseCase();
    await super.close();
  }
}
