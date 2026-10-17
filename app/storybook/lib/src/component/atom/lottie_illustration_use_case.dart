import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Lottie Illustration', type: DSLottieIllustrationWidget)
Widget buildLottieIllustration(BuildContext context) {
  final illustration = context.knobs.object.dropdown(
    label: 'Illustration',
    options: DSLottieIllustration.values,
    initialOption: DSLottieIllustration.developerRole,
    labelBuilder: (illustration) => illustration.name,
  );
  final width = context.knobs.double.slider(
    label: 'Width',
    initialValue: 280,
    min: 80,
    max: 600,
  );
  final playback = context.knobs.object.dropdown(
    label: 'Playback',
    options: [DSLottiePlayback.once, DSLottiePlayback.loop],
    initialOption: DSLottiePlayback.loop,
    labelBuilder: (playback) => playback.name,
  );
  final useThemeColors = context.knobs.boolean(
    label: 'Use Theme Colors',
    initialValue: true,
  );

  return Center(
    child: DSLottieIllustrationWidget(
      key: ValueKey('$illustration-$playback-$useThemeColors'),
      illustration: illustration,
      width: width,
      playback: playback,
      useThemeColors: useThemeColors,
    ),
  );
}
