import 'dart:async';

import 'package:module_injector/module_injector.dart';

/// Signals in-memory flag mutations, including mutations whose persistence fails.
@RegisterSingleton(disposeMethodName: 'close')
class AppFeatureFlagChanges {
  final _controller = StreamController<String?>.broadcast(sync: true);

  Stream<String?> get stream => _controller.stream;

  void notify([String? key]) => _controller.add(key);

  Future<void> close() => _controller.close();
}
