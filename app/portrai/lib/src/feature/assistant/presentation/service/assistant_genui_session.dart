import 'dart:async';

import 'package:genui/genui.dart';
import 'package:portrai/src/feature/assistant/presentation/catalog/assistant_catalog.dart';

typedef AssistantGenuiGenerate<T> =
    Future<T> Function(
      ChatMessage message,
      String systemPrompt,
      void Function(String) onDelta,
    );

/// Presentation runtime only: the caller owns generation and domain results.
class AssistantGenuiSession {
  AssistantGenuiSession() {
    _controller = SurfaceController(catalogs: [_catalog]);
    systemPrompt = PromptBuilder.chat(catalog: _catalog).systemPromptJoined();
  }

  final Catalog _catalog = createAssistantCatalog();
  late SurfaceController _controller;
  late final String systemPrompt;
  SurfaceController get controller => _controller;
  void Function()? _closeTurn;
  bool _disposed = false;

  Future<T> send<T>(
    ChatMessage message, {
    required AssistantGenuiGenerate<T> generate,
  }) {
    if (_disposed || _closeTurn != null) {
      return Future.error(StateError('Session disposed or turn still active'));
    }
    final completion = Completer<T>();
    var closed = false;
    late A2uiTransportAdapter transport;
    late StreamSubscription<dynamic> subscription;
    late void Function() invalidate;
    void close() {
      if (closed) return;
      closed = true;
      unawaited(subscription.cancel());
      transport.dispose();
      if (identical(_closeTurn, invalidate)) _closeTurn = null;
    }

    invalidate = () {
      if (!completion.isCompleted) {
        completion.completeError(StateError('Turn invalidated'));
      }
      close();
    };
    // 0.10.4's internal parser listener has no onError. Contain that listener's
    // asynchronous errors in this turn, without logging generated payloads.
    runZonedGuarded(
      () async {
        late T result;
        transport = A2uiTransportAdapter(
          onSend: (request) async {
            result = await generate(request, systemPrompt, (delta) {
              if (!closed) transport.addChunk(delta);
            });
          },
        );
        subscription = transport.incomingMessages.listen(
          _controller.handleMessage,
        );
        _closeTurn = invalidate;
        try {
          // Start the lazy parser even when generation emits no deltas.
          transport.addChunk('');
          await transport.sendRequest(message);
          if (closed) return;
          // flush ends this parser's input; every turn needs a fresh adapter.
          await transport.flush();
          if (!completion.isCompleted) completion.complete(result);
        } finally {
          close();
        }
      },
      (error, stack) {
        if (!completion.isCompleted) completion.completeError(error, stack);
        close();
      },
    );
    return completion.future;
  }

  /// Unmount surfaces first. Invalidates deltas, not backend generation.
  void reset() {
    if (_disposed) throw StateError('Session disposed');
    _invalidate();
    _controller = SurfaceController(catalogs: [_catalog]);
  }

  void _invalidate() {
    _closeTurn?.call();
    _controller.dispose();
  }

  /// Unmount surfaces before disposing their owner.
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    _invalidate();
  }
}
