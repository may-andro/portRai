import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Runs before every test file in this package.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Visibility detectors report through a timer that would stay pending.
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  await testMain();
}
