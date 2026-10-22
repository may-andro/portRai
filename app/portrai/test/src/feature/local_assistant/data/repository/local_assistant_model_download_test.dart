import 'dart:async';

import 'package:flutter_edge_ai/flutter_edge_ai.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/local_assistant/data/repository/local_assistant_model_download.dart';

void main() {
  // An installer that reports progress on request and finishes on request.
  ({
    LocalAssistantModelInstaller install,
    void Function(int) report,
    Completer<void> finish,
    List<CancelToken> starts,
  })
  controlledInstaller() {
    final starts = <CancelToken>[];
    final finish = Completer<void>();
    void Function(int)? reportProgress;
    Future<void> install(
      CancelToken cancelToken,
      void Function(int) onProgress,
    ) {
      starts.add(cancelToken);
      reportProgress = onProgress;
      cancelToken.whenCancelled.then((_) {
        if (!finish.isCompleted) {
          finish.completeError(StateError('Cancelled'));
        }
      });
      return finish.future;
    }

    return (
      install: install,
      report: (progress) => reportProgress!(progress),
      finish: finish,
      starts: starts,
    );
  }

  test('should start one download when two callers run at once', () async {
    final download = LocalAssistantModelDownload();
    final installer = controlledInstaller();
    final firstProgress = <int>[];
    final secondProgress = <int>[];

    final first = download.run(
      installer.install,
      onProgress: firstProgress.add,
    );
    final second = download.run(
      installer.install,
      onProgress: secondProgress.add,
    );
    installer.report(40);
    installer.finish.complete();
    await Future.wait([first, second]);

    expect(installer.starts, hasLength(1));
    expect(firstProgress, [40]);
    expect(secondProgress, [0, 40]);
    expect(download.isRunning, isFalse);
  });

  test('should give a joining caller the progress so far', () async {
    final download = LocalAssistantModelDownload();
    final installer = controlledInstaller();
    final first = download.run(installer.install, onProgress: (_) {});
    installer.report(65);
    final joinedProgress = <int>[];

    final joined = download.run(
      installer.install,
      onProgress: joinedProgress.add,
    );
    installer.finish.complete();
    await Future.wait([first, joined]);

    expect(joinedProgress, [65]);
  });

  test('should start a new download when the previous one ended', () async {
    final download = LocalAssistantModelDownload();
    var installs = 0;
    Future<void> install(CancelToken _, void Function(int) _) async {
      installs++;
    }

    await download.run(install, onProgress: (_) {});
    await download.run(install, onProgress: (_) {});

    expect(installs, 2);
  });

  test('should fail every caller when the download fails', () async {
    final download = LocalAssistantModelDownload();
    final installer = controlledInstaller();
    final first = download.run(installer.install, onProgress: (_) {});
    final second = download.run(installer.install, onProgress: (_) {});

    installer.finish.completeError(StateError('Offline'));

    await expectLater(first, throwsStateError);
    await expectLater(second, throwsStateError);
    expect(download.isRunning, isFalse);
  });

  test('should stop the running download when cancelled', () async {
    final download = LocalAssistantModelDownload();
    final installer = controlledInstaller();
    final running = download.run(installer.install, onProgress: (_) {});

    await download.cancel('Turned off');

    expect(installer.starts.single.isCancelled, isTrue);
    await expectLater(running, throwsStateError);
    expect(download.isRunning, isFalse);
  });

  test('should do nothing when cancelled with no download running', () async {
    await LocalAssistantModelDownload().cancel('Turned off');
  });
}
