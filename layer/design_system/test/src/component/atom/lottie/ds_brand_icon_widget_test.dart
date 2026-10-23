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

    test('should return resume and website when they are named', () {
      expect(DSBrandIcon.fromName('Resume'), DSBrandIcon.resume);
      expect(DSBrandIcon.fromName('Website'), DSBrandIcon.website);
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

    for (final brand in DSBrandIcon.values) {
      testWidgets('should load the animation when brand is ${brand.name}', (
        tester,
      ) async {
        await tester.pumpWidget(
          TestWidgetWrapper(
            brightness: Brightness.light,
            designSystem: DesignSystem.values.first,
            child: DSBrandIconWidget(brand: brand, size: 48),
          ),
        );
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(seconds: 1)),
        );
        await tester.pump();

        expect(find.byType(RawLottie), findsOneWidget);
        expect(find.byIcon(brand.fallbackIcon), findsNothing);
      });
    }

    testWidgets('should paint the circle with primary when no color is given', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      final lottie = tester.widget<DSLottieWidget>(find.byType(DSLottieWidget));
      final context = tester.element(find.byType(DSLottieWidget));
      expect(
        lottie.colorOverrides.first.color,
        context.colorPalette.brand.primary,
      );
    });

    testWidgets('should paint the circle and mark with the given colors', (
      tester,
    ) async {
      const color = DSColor(0xFF112233);
      const onColor = DSColor(0xFF445566);
      await tester.pumpWidget(
        TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.values.first,
          child: const DSBrandIconWidget(
            brand: DSBrandIcon.github,
            size: 48,
            color: color,
            onColor: onColor,
          ),
        ),
      );

      final lottie = tester.widget<DSLottieWidget>(find.byType(DSLottieWidget));
      expect(lottie.colorOverrides.map((override) => override.color), [
        color,
        onColor,
      ]);
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
