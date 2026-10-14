import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../util/test_wrapper_widget.dart';

void main() {
  setUp(() {
    VisibilityDetectorController.instance.updateInterval = Duration.zero;
  });

  for (final icon in DSLottieIcon.values) {
    testWidgets('should load the ${icon.name} animation when it is shown', (
      tester,
    ) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.values.first,
          child: DSLottieIconWidget(icon: icon, size: 48, color: Colors.white),
        ),
      );
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
      final controller = lottie.controller! as AnimationController;
      expect(controller.duration, isNotNull);
      expect(find.byType(Icon), findsNothing);
    });
  }

  group('trigger playback', () {
    Widget buildSubject(int trigger) => TestWidgetWrapper(
      brightness: Brightness.light,
      designSystem: DesignSystem.values.first,
      child: DSLottieIconWidget(
        icon: DSLottieIcon.paperPlane,
        size: 48,
        color: Colors.white,
        playback: DSLottiePlayback.trigger,
        trigger: trigger,
      ),
    );

    AnimationController controllerOf(WidgetTester tester) =>
        tester.widget<LottieBuilder>(find.byType(LottieBuilder)).controller!
            as AnimationController;

    testWidgets('should stay idle when it is shown without a trigger', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject(0));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(controllerOf(tester).value, 0);
    });

    testWidgets('should play when the trigger changes', (tester) async {
      await tester.pumpWidget(buildSubject(0));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();

      await tester.pumpWidget(buildSubject(1));
      await tester.pump(const Duration(milliseconds: 300));

      expect(controllerOf(tester).value, greaterThan(0));
    });
  });
}
