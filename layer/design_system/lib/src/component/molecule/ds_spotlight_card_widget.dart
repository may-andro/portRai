import 'package:design_system/src/component/molecule/ds_hoverable_container_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// A tappable card with a subtle translucent fill. A radial [glowColor]
/// spotlight sits in the top-left corner and grows, together with the border,
/// when hovered. [builder] receives the hover state so content (e.g. an arrow)
/// can react to it.
class DSSpotlightCardWidget extends StatelessWidget {
  const DSSpotlightCardWidget({
    super.key,
    required this.builder,
    required this.glowColor,
    required this.fillColor,
    this.background,
    this.onTap,
    this.padding,
  });

  final Widget Function(BuildContext context, bool isHovering) builder;
  final DSColor glowColor;
  final DSColor fillColor;

  /// Painted behind the content and clipped to the card's rounded shape; use
  /// a [Stack] with positioned children to place decorative art.
  final Widget? background;

  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final glow = glowColor.color;
    final fill = fillColor.color;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);

    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, isHovering ? -4 : 0, 0),
          decoration: BoxDecoration(
            borderRadius: radius,
            color: fill.withAlpha(14),
            border: Border.all(
              color: isHovering ? glow : fill.withAlpha(40),
              width: isHovering ? 1.5 : 1,
            ),
            gradient: RadialGradient(
              center: Alignment.topLeft,
              radius: isHovering ? 1.3 : 0.9,
              colors: [
                glow.withAlpha(isHovering ? 90 : 55),
                Colors.transparent,
              ],
            ),
          ),
          child: Stack(
            children: [
              if (background case final Widget background)
                Positioned.fill(
                  child: ClipRRect(borderRadius: radius, child: background),
                ),
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: radius,
                  child: Padding(
                    padding:
                        padding ?? EdgeInsets.all(context.space(factor: 2.5)),
                    child: builder(context, isHovering),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
