import 'dart:async';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';

/// Installs the model file, reporting progress from 0 to 100 and stopping
/// when [cancelToken] is cancelled.
typedef LocalAssistantModelInstaller =
    Future<void> Function(
      CancelToken cancelToken,
      void Function(int progress) onProgress,
    );

/// The single model download of the app process.
///
/// An in-app restart resets the service locator, which disposes the
/// repository and creates a new one while the old download keeps running.
/// Both instances share this object instead of their own state, so a second
/// caller joins the running download rather than starting another one on
/// the same file.
class LocalAssistantModelDownload {
  LocalAssistantModelDownload();

  /// The instance every repository of this process uses.
  static final process = LocalAssistantModelDownload();

  Future<void>? _running;
  CancelToken? _cancelToken;
  int _progress = 0;
  final _progressUpdates = StreamController<int>.broadcast(sync: true);

  /// Whether a download is running.
  bool get isRunning => _running != null;

  /// Runs [install], or joins the download already running. [onProgress]
  /// receives this download's progress, starting with the progress reached
  /// so far when joining.
  Future<void> run(
    LocalAssistantModelInstaller install, {
    required void Function(int progress) onProgress,
  }) async {
    final subscription = _progressUpdates.stream.listen(onProgress);
    try {
      final running = _running;
      if (running != null) {
        onProgress(_progress);
        await running;
      } else {
        await (_running = _start(install));
      }
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> _start(LocalAssistantModelInstaller install) async {
    final cancelToken = _cancelToken = CancelToken();
    _progress = 0;
    try {
      await install(cancelToken, (progress) {
        _progress = progress;
        _progressUpdates.add(progress);
      });
    } finally {
      _running = null;
      _cancelToken = null;
    }
  }

  /// Cancels the running download, if any, and waits until it has stopped.
  Future<void> cancel(String reason) async {
    final running = _running;
    _cancelToken?.cancel(reason);
    try {
      await running;
    } on Object {
      // A cancelled download is expected to fail.
    }
  }
}
