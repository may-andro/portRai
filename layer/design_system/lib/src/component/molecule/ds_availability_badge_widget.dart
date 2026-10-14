import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// A pill badge with a Lottie-pulsing status dot, used to flag availability
/// (e.g. "Available for work"). [color] tints the dot, border and background.
class DSAvailabilityBadgeWidget extends StatelessWidget {
  const DSAvailabilityBadgeWidget({
    super.key,
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final DSColor textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.5),
        vertical: context.space(factor: 0.75),
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(),
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DSLottieIllustrationWidget(
                  illustration: DSLottieIllustration.pinPulse,
                  width: 20,
                  colorOverrides: [
                    DSLottieColorOverride(
                      keyPath: const ['Pulse', '**'],
                      color: DSColor(color.toARGB32()),
                    ),
                  ],
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: DSTextWidget(
              label,
              style: context.typography.emphasizedLabelMedium,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
