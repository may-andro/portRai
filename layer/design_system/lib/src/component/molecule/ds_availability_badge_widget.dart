import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A pill badge with a pulsing status dot, used to flag availability
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
            width: 14,
            height: 14,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withAlpha(90),
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      end: const Offset(1.4, 1.4),
                      duration: 1500.ms,
                    )
                    .fadeOut(duration: 1500.ms),
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
