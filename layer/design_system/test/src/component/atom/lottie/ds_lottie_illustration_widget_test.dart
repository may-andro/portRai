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

  testWidgets('should size the illustration by its aspect ratio when shown', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.values.first,
        child: const Center(
          child: DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.heroOrbs,
            width: 400,
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(LottieBuilder)), const Size(400, 225));
  });

  for (final illustration in [
    DSLottieIllustration.developerRole,
    DSLottieIllustration.recruiterRole,
    DSLottieIllustration.explorerRole,
    DSLottieIllustration.techStack,
    DSLottieIllustration.computerWindow,
    DSLottieIllustration.talentSearch,
    DSLottieIllustration.signIn,
    DSLottieIllustration.binoculars,
    DSLottieIllustration.calendarBooking,
    DSLottieIllustration.appointment,
    DSLottieIllustration.confetti,
    DSLottieIllustration.logo,
  ]) {
    testWidgets('should size ${illustration.name} by its aspect ratio when '
        'shown', (tester) async {
      await tester.pumpWidget(
        TestWidgetWrapper(
          brightness: Brightness.light,
          designSystem: DesignSystem.values.first,
          child: Center(
            child: DSLottieIllustrationWidget(
              illustration: illustration,
              width: 266,
            ),
          ),
        ),
      );

      expect(
        tester.getSize(find.byType(LottieBuilder)),
        Size(266, 266 / illustration.aspectRatio),
      );
    });
  }

  testWidgets('should fill its parent and apply the grayscale filter when '
      'used as a background', (tester) async {
    await tester.pumpWidget(
      TestWidgetWrapper(
        brightness: Brightness.light,
        designSystem: DesignSystem.values.first,
        child: const DSLottieBackgroundWidget(
          illustration: DSLottieIllustration.contactUs,
          grayscale: true,
        ),
      ),
    );

    expect(find.byType(ColorFiltered), findsOneWidget);
    expect(find.byType(Opacity), findsOneWidget);
  });
}
