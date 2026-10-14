import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// A glass-style info tile with a diagonal gradient between [startColor] and
/// [endColor]: a gradient icon badge next to a small caps [label] and a
/// prominent [value]. Text is drawn with [textColor], so the tile works on both
/// light and dark backgrounds.
class DSIconInfoTileWidget extends StatelessWidget {
  const DSIconInfoTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.startColor,
    required this.endColor,
    required this.textColor,
    this.iconWidget,
  });

  final IconData icon;
  final String label;
  final String value;
  final DSColor startColor;
  final DSColor endColor;
  final DSColor textColor;

  /// Replaces the [icon] badge entirely, e.g. with an animated icon, so it
  /// sizes itself and gets no gradient container.
  final Widget? iconWidget;

  @override
  Widget build(BuildContext context) {
    final start = startColor.color;
    final end = endColor.color;
    final text = textColor.color;
    final isCompact = context.isDesktop;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: Color.lerp(start, end, 0.5)!.withAlpha(120)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [start.withAlpha(90), end.withAlpha(60)],
        ),
        boxShadow: [
          BoxShadow(
            color: start.withAlpha(40),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: isCompact ? 1 : 1.5)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: isCompact ? 1 : 1.5),
          children: [
            iconWidget ??
                Container(
                  padding: EdgeInsets.all(
                    context.space(factor: isCompact ? 0.75 : 1),
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      context.dimen.radiusLevel1.value,
                    ),
                    gradient: LinearGradient(colors: [start, end]),
                  ),
                  child: Icon(
                    icon,
                    size: isCompact ? 16 : 20,
                    color: Colors.white,
                  ),
                ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: context.typography.labelSmall.textStyle.copyWith(
                      color: text.withAlpha(170),
                      letterSpacing: 1.2,
                    ),
                  ),
                  DSTextWidget(
                    value,
                    style: isCompact
                        ? context.typography.emphasizedBodySmall
                        : context.typography.emphasizedBodyMedium,
                    color: textColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
