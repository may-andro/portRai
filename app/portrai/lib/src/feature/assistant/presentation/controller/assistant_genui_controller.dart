import 'dart:async';

import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_catalog.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_map_locations.dart';

typedef AssistantGenuiGenerate<T> =
    Future<T> Function(
      ChatMessage message,
      String systemPrompt,
      void Function(String) onDelta,
    );

class AssistantGenuiResponseException implements Exception {
  const AssistantGenuiResponseException();

  @override
  String toString() => 'AssistantGenuiResponseException';
}

class AssistantGenuiTurnCancelledException implements Exception {
  const AssistantGenuiTurnCancelledException();

  @override
  String toString() => 'AssistantGenuiTurnCancelledException';
}

/// Presentation runtime only: the caller owns generation and domain results.
class AssistantGenuiController {
  AssistantGenuiController({
    Iterable<String> allowedImageUrls = const [],
    List<AssistantLocation> allowedLocations = const [],
  }) : supportsImages = allowedImageUrls.isNotEmpty,
       supportsMaps = allowedLocations.isNotEmpty,
       _catalog = createAssistantCatalog(
         allowedImageUrls: allowedImageUrls.toSet(),
         allowedLocations: allowedLocations,
       ) {
    _controller = SurfaceController(catalogs: [_catalog]);
    systemPrompt = PromptBuilder.chat(catalog: _catalog).systemPromptJoined();
    _listenForFrameworkErrors();
  }

  final Catalog _catalog;
  final bool supportsImages;
  final bool supportsMaps;
  late SurfaceController _controller;
  late final String systemPrompt;
  SurfaceController get surfaceController => _controller;
  final _frameworkErrors =
      StreamController<AssistantGenuiResponseException>.broadcast();
  void Function()? _closeTurn;
  bool _disposed = false;
  bool _controllerDisposed = false;
  bool _reportedFrameworkError = false;
  bool _parserFailed = false;
  int _surfaceReferences = 0;

  Stream<AssistantGenuiResponseException> get frameworkErrors =>
      _frameworkErrors.stream;

  Iterable<String> get activeSurfaceIds => _controller.activeSurfaceIds;

  void Function() acquireSurface() {
    if (_controllerDisposed) throw StateError('Session surfaces are disposed');
    _surfaceReferences++;
    var released = false;
    return () {
      if (released) return;
      released = true;
      _surfaceReferences--;
      _disposeControllerIfUnused();
    };
  }

  Future<T> send<T>(
    ChatMessage message, {
    required AssistantGenuiGenerate<T> generate,
    void Function(String text)? onText,
    void Function(SurfaceUpdate update)? onSurfaceUpdate,
  }) {
    if (_disposed || _closeTurn != null) {
      return Future.error(StateError('Session disposed or turn still active'));
    }
    final completion = Completer<T>();
    var closed = false;
    late A2uiTransportAdapter transport;
    late StreamSubscription<dynamic> messageSubscription;
    late StreamSubscription<dynamic> textSubscription;
    late StreamSubscription<dynamic> surfaceSubscription;
    late void Function() invalidate;
    void close() {
      if (closed) return;
      closed = true;
      unawaited(messageSubscription.cancel());
      unawaited(textSubscription.cancel());
      unawaited(surfaceSubscription.cancel());
      transport.dispose();
      if (identical(_closeTurn, invalidate)) _closeTurn = null;
    }

    invalidate = () {
      if (!completion.isCompleted) {
        completion.completeError(const AssistantGenuiTurnCancelledException());
      }
      close();
    };
    _reportedFrameworkError = false;
    _parserFailed = false;
    // 0.10.4's internal parser listener has no onError. Contain its async
    // errors in this turn, without logging generated payloads.
    runZonedGuarded(
      () async {
        try {
          late T result;
          transport = A2uiTransportAdapter(
            onSend: (request) async {
              result = await generate(request, systemPrompt, (delta) {
                if (!closed) transport.addChunk(delta);
              });
            },
          );
          messageSubscription = transport.incomingMessages.listen((message) {
            try {
              _controller.handleMessage(message);
            } catch (_) {
              _reportFrameworkError();
            }
          }, onError: (Object _, StackTrace _) => _reportFrameworkError());
          textSubscription = transport.incomingText.listen(
            (text) => onText?.call(text),
            onError: (Object _, StackTrace _) {
              _parserFailed = true;
              _reportFrameworkError();
            },
          );
          surfaceSubscription = _controller.surfaceUpdates.listen(
            (update) => onSurfaceUpdate?.call(update),
            onError: (Object _, StackTrace _) => _reportFrameworkError(),
          );
          _closeTurn = invalidate;
          // Start the lazy parser even when generation emits no deltas.
          transport.addChunk('');
          await transport.sendRequest(message);
          if (closed) return;
          // flush ends this parser's input; every turn needs a fresh adapter.
          await transport.flush();
          await Future<void>.delayed(Duration.zero);
          if (closed) return;
          if (_reportedFrameworkError || _parserFailed) {
            throw const AssistantGenuiResponseException();
          }
          if (!completion.isCompleted) completion.complete(result);
        } catch (error, stackTrace) {
          if (!completion.isCompleted) {
            completion.completeError(
              error is AssistantGenuiTurnCancelledException
                  ? error
                  : const AssistantGenuiResponseException(),
              stackTrace,
            );
          }
        } finally {
          close();
        }
      },
      (error, stack) {
        if (!completion.isCompleted) {
          completion.completeError(
            const AssistantGenuiResponseException(),
            stack,
          );
        }
        close();
      },
    );
    return completion.future;
  }

  /// Unmount surfaces first. Invalidates deltas, not backend generation.
  void reset() {
    if (_disposed) throw StateError('Session disposed');
    if (_surfaceReferences > 0) {
      throw StateError('Unmount session surfaces before resetting');
    }
    _invalidate();
    _controllerDisposed = false;
    _controller = SurfaceController(catalogs: [_catalog]);
    _listenForFrameworkErrors();
  }

  void _invalidate() {
    _closeTurn?.call();
    _disposeControllerIfUnused();
  }

  /// Unmount surfaces before disposing their owner.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _invalidate();
  }

  StreamSubscription<ChatMessage>? _errorSubscription;

  void _listenForFrameworkErrors() {
    _errorSubscription = _controller.onSubmit.listen((_) {
      _reportFrameworkError();
    });
  }

  void _reportFrameworkError() {
    if (_reportedFrameworkError) return;
    _reportedFrameworkError = true;
    if (!_frameworkErrors.isClosed) {
      _frameworkErrors.add(const AssistantGenuiResponseException());
    }
  }

  void _disposeControllerIfUnused() {
    if (_controllerDisposed || _surfaceReferences > 0) return;
    _controllerDisposed = true;
    unawaited(_errorSubscription?.cancel());
    _controller.dispose();
    if (_disposed && !_frameworkErrors.isClosed) {
      unawaited(_frameworkErrors.close());
    }
  }
}
