import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Sizes the test surface like a desktop window, tall enough to build a whole
/// page, and makes `VisibilityDetector` report synchronously so scroll
/// reveals run. Resets the surface after the test.
void setUpAnimatedPage(
  WidgetTester tester, {
  Size size = const Size(1440, 2400),
}) {
  VisibilityDetectorController.instance.updateInterval = Duration.zero;
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Advances time in frames until entrance animations have finished. Use it
/// instead of `pumpAndSettle` on pages with looping background animations.
Future<void> pumpAnimations(WidgetTester tester) async {
  for (var frame = 0; frame < 30; frame++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
