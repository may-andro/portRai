import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/component/molecule/ds_hoverable_container_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A tinted skill card with an animated proficiency meter.
///
/// The card lifts and glows with an [accent] colour on hover, and the meter
/// fills up to [progress] (0..1) when it first appears. [levelLabel],
/// [description] and [details] are optional captions around the meter.
class DSSkillCardWidget extends StatelessWidget {
  const DSSkillCardWidget({
    super.key,
    required this.name,
    required this.accent,
    this.description,
    this.levelLabel,
    this.progress,
    this.details,
    this.animateProgress = true,
  });

  final String name;
  final Color accent;
  final String? description;
  final String? levelLabel;

  /// Proficiency between 0 and 1. The meter is hidden when null.
  final double? progress;
  final String? details;

  /// Whether the meter fills up with an animation when first shown.
  final bool animateProgress;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final progress = this.progress;

    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, isHovering ? -4 : 0, 0),
          padding: EdgeInsets.all(context.space(factor: 2)),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: accent.withAlpha(isHovering ? 44 : 22),
            border: Border.all(color: accent.withAlpha(isHovering ? 190 : 70)),
            boxShadow: [
              BoxShadow(
                color: accent.withAlpha(isHovering ? 110 : 0),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(),
            children: [
              Row(
                spacing: context.space(),
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: isHovering ? 12 : 8,
                    height: isHovering ? 12 : 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: DSTextWidget(
                      name,
                      style: context.typography.emphasizedTitleMedium,
                      color: palette.neutral.grey9,
                      maxLines: 2,
                      textOverflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (levelLabel != null)
                    DSTextWidget(
                      levelLabel!,
                      style: context.typography.labelSmall,
                      color: palette.neutral.grey9,
                    ),
                ],
              ),
              if (description != null)
                DSTextWidget(
                  description!,
                  style: context.typography.bodySmall,
                  color: palette.neutral.grey9,
                ),
              if (progress != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    height: 6,
                    color: palette.neutral.grey9.color.withAlpha(25),
                    alignment: Alignment.centerLeft,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: animateProgress ? 0 : progress.clamp(0, 1),
                        end: progress.clamp(0, 1),
                      ),
                      duration: animateProgress
                          ? const Duration(milliseconds: 900)
                          : Duration.zero,
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return FractionallySizedBox(
                          widthFactor: value,
                          heightFactor: 1,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [accent.withAlpha(120), accent],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              if (details != null)
                DSTextWidget(
                  details!,
                  style: context.typography.labelSmall,
                  color: palette.neutral.grey9,
                ),
            ],
          ),
        );
      },
    );
  }
}
