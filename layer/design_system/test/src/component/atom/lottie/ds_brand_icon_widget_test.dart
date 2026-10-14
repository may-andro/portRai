import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../../../util/test_wrapper_widget.dart';

void main() {
  group('DSBrandIcon.fromName', () {
    test('should return linkedin when name is LinkedIn in any casing', () {
      expect(DSBrandIcon.fromName('LinkedIn'), DSBrandIcon.linkedin);
      expect(DSBrandIcon.fromName(' linkedin '), DSBrandIcon.linkedin);
    });

    test('should return github when name is GitHub in any casing', () {
      expect(DSBrandIcon.fromName('GitHub'), DSBrandIcon.github);
    });

    test('should return null when the brand is unknown', () {
      expect(DSBrandIcon.fromName('unknown'), isNull);
    });
  });

  group('DSBrandIconWidget', () {
    setUp(() {
      VisibilityDetectorController.instance.updateInterval = Duration.zero;
    });

    Widget buildSubject({DSLottiePlayback playback = DSLottiePlayback.once}) =>
        TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.values.first,
          child: DSBrandIconWidget(
            brand: DSBrandIcon.linkedin,
            size: 48,
            playback: playback,
          ),
        );

    Future<void> settle(WidgetTester tester) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 200)),
      );
      await tester.pump();
      await tester.pump();
    }

    testWidgets('should render the lottie animation when it is shown', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());
      await tester.pump();

      expect(find.byType(DSLottieWidget), findsOneWidget);
      expect(find.byType(LottieBuilder), findsOneWidget);
    });

    testWidgets('should play once when it enters the viewport', (tester) async {
      await tester.pumpWidget(buildSubject());
      await settle(tester);
      await tester.pump(const Duration(seconds: 5));

      final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
      expect(lottie.controller!.status, AnimationStatus.completed);
    });

    testWidgets('should keep animating when playback is loop', (tester) async {
      await tester.pumpWidget(buildSubject(playback: DSLottiePlayback.loop));
      await settle(tester);
      await tester.pump(const Duration(seconds: 5));

      final lottie = tester.widget<LottieBuilder>(find.byType(LottieBuilder));
      expect(lottie.controller!.isAnimating, isTrue);
    });
  });
}
