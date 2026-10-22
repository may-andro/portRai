import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/feature_flag/feature_flag.dart';
import 'package:portrai/src/feature/remote_assistant/domain/_domain.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/controller/remote_assistant_genui_controller_extension.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_event.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/remote_assistant_state.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/tracking/_tracking.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

/// The links, contact links and places the generated UI may show, derived
/// from [portfolioContext].
typedef _AllowedContent = ({
  String portfolioContext,
  Set<String> urls,
  Set<String> contactLinks,
  List<AssistantLocation> locations,
});

@RegisterSingleton(disposeMethodName: 'close')
class RemoteAssistantBloc
    extends Bloc<RemoteAssistantEvent, RemoteAssistantState> {
  RemoteAssistantBloc(
    this._getAssistantContextUseCase,
    this._resetRemoteAssistantSessionUseCase,
    this._askRemotePortfolioQuestionUseCase,
    this._isFeatureEnabledUseCase,
    this._isRemoteAssistantSupportedUseCase,
    this._openExternalUrlUseCase,
    this._trackingDelegate,
    this._getGuestUserUseCase,
  ) : super(const RemoteAssistantState()) {
    on<RemoteAssistantStartedEvent>(_mapRemoteAssistantStartedEventToState);
    on<RemoteAssistantInitializedEvent>(
      _mapRemoteAssistantInitializedEventToState,
    );
    on<ResetRemoteAssistantClickEvent>(
      _mapResetRemoteAssistantClickEventToState,
    );
    on<OpenRemoteAssistantLinkClickEvent>(
      _mapOpenRemoteAssistantLinkClickEventToState,
    );
    on<SendRemoteAssistantQuestionClickEvent>(
      _mapSendRemoteAssistantQuestionClickEventToState,
    );
  }

  final GetAssistantContextUseCase _getAssistantContextUseCase;
  final ResetRemoteAssistantSessionUseCase _resetRemoteAssistantSessionUseCase;
  final AskRemotePortfolioQuestionUseCase _askRemotePortfolioQuestionUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final IsFeatureEnabledUseCase _isFeatureEnabledUseCase;
  final IsRemoteAssistantSupportedUseCase _isRemoteAssistantSupportedUseCase;
  final RemoteAssistantTrackingDelegate _trackingDelegate;
  final GetGuestUserUseCase _getGuestUserUseCase;
  int _controlRevision = 0;
  int _requestRevision = 0;
  final Set<AssistantGenuiController> _genuiControllers = {};
  final Map<
    AssistantGenuiController,
    StreamSubscription<AssistantGenuiResponseException>
  >
  _genuiErrorSubscriptions = {};
  // What the generated UI may show for the loaded portfolio context. It is
  // derived once per context and reused by every question.
  _AllowedContent? _allowedContent;

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
        _disposeGenuiControllers();
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
        _disposeGenuiControllers();
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
    _disposeGenuiControllers();
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
    final userEither = await _getGuestUserUseCase();
    if (emit.isDone || revision != _controlRevision) return;
    emit(
      state.copyWith(
        status: RemoteAssistantStatus.ready,
        userRole: userEither.isRight ? userEither.right?.role : null,
      ),
    );
    if (state.portfolioContext == null) await _loadContext(emit, revision);
  }

  Future<void> _loadContext(
    Emitter<RemoteAssistantState> emit,
    int revision,
  ) async {
    emit(state.copyWith(isLoadingContext: true, clearFailure: true));
    final result = await _getAssistantContextUseCase();
    if (emit.isDone || revision != _controlRevision || !state.isReady) return;
    if (result.isRight) _allowedContentOf(result.right);
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

  _AllowedContent _allowedContentOf(String portfolioContext) {
    final cachedContent = _allowedContent;
    if (cachedContent != null &&
        cachedContent.portfolioContext == portfolioContext) {
      return cachedContent;
    }
    Object? portfolio;
    try {
      portfolio = jsonDecode(portfolioContext);
    } on FormatException {
      portfolio = null;
    }
    return _allowedContent = (
      portfolioContext: portfolioContext,
      urls: assistantUrlsFrom(portfolioContext),
      contactLinks: assistantContactLinksFrom(portfolio),
      locations: assistantLocationsFrom(portfolio),
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
    _disposeGenuiControllers();
    final result = await _resetRemoteAssistantSessionUseCase();
    if (!emit.isDone && revision == _requestRevision && result.isLeft) {
      emit(state.copyWith(failure: result.left));
    }
  }

  Future<void> _mapOpenRemoteAssistantLinkClickEventToState(
    OpenRemoteAssistantLinkClickEvent event,
    Emitter<RemoteAssistantState> emit,
  ) async {
    final uri = Uri.tryParse(event.url);
    if (uri == null) return;
    _trackingDelegate.trackLinkClick();
    await _openExternalUrlUseCase(OpenExternalUrlParam(uri));
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
    if (event.isSuggestion) {
      _trackingDelegate.trackSuggestionClick();
    } else {
      _trackingDelegate.trackQuestionSubmission();
    }
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
    final AssistantGenuiController? genuiController;
    final Either<RemoteAssistantFailure, void> result;
    if (state.isGenerativeUiEnabled) {
      final allowedContent = _allowedContentOf(state.portfolioContext!);
      final controller = AssistantGenuiController(
        allowedUrls: allowedContent.urls,
        allowedContactLinks: allowedContent.contactLinks,
        allowedLocations: allowedContent.locations,
        onOpenLink: (url) => add(OpenRemoteAssistantLinkClickEvent(url)),
        onAskQuestion: (question) => add(
          SendRemoteAssistantQuestionClickEvent(question, isSuggestion: true),
        ),
      );
      genuiController = controller;
      _genuiControllers.add(controller);
      _genuiErrorSubscriptions[controller] = controller.frameworkErrors.listen(
        (_) => _handleGenuiFrameworkError(emit, controller),
      );
      final surfaceMessageIndex = messages.length;
      result = await controller.sendPortfolioQuestion(
        askRemotePortfolioQuestionUseCase: _askRemotePortfolioQuestionUseCase,
        question: question,
        portfolioContext: state.portfolioContext!,
        history: boundedHistory,
        userRole: state.userRole,
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
              .where(
                (surface) => !identical(surface.genuiController, controller),
              )
              .toList();
          currentSurfaces.addAll(
            controller.activeSurfaceIds.map(
              (surfaceId) => RemoteAssistantSurface(
                messageIndex: surfaceMessageIndex,
                genuiController: controller,
                surfaceId: surfaceId,
              ),
            ),
          );
          emit(state.copyWith(genuiSurfaces: currentSurfaces));
        },
      );
    } else {
      genuiController = null;
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
      if (genuiController != null) _retireGenuiController(genuiController);
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
    if (genuiController != null && genuiController.activeSurfaceIds.isEmpty) {
      completedSurfaces = completedSurfaces
          .where(
            (surface) => !identical(surface.genuiController, genuiController),
          )
          .toList();
      _retireGenuiController(genuiController);
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
              genuiController: surface.genuiController,
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
    _retainGenuiControllers(completedSurfaces);
  }

  void _retainGenuiControllers(Iterable<RemoteAssistantSurface> surfaces) {
    final retained = surfaces.map((surface) => surface.genuiController).toSet();
    for (final genuiController in _genuiControllers.toList()) {
      if (!retained.contains(genuiController)) {
        _retireGenuiController(genuiController);
      }
    }
  }

  void _retireGenuiController(AssistantGenuiController genuiController) {
    _genuiErrorSubscriptions.remove(genuiController)?.cancel();
    if (_genuiControllers.remove(genuiController)) {
      genuiController.dispose();
    }
  }

  void _disposeGenuiControllers() {
    for (final genuiController in _genuiControllers.toList()) {
      _retireGenuiController(genuiController);
    }
  }

  void _handleGenuiFrameworkError(
    Emitter<RemoteAssistantState> emit,
    AssistantGenuiController genuiController,
  ) {
    if (emit.isDone || !_genuiControllers.contains(genuiController)) return;
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
    _disposeGenuiControllers();
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
    _disposeGenuiControllers();
    await _resetRemoteAssistantSessionUseCase();
    await super.close();
  }
}
