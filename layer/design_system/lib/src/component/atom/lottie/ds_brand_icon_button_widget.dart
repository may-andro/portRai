import 'package:design_system/src/component/atom/lottie/ds_brand_icon_widget.dart';
import 'package:design_system/src/component/atom/lottie/ds_lottie_widget.dart';
import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:flutter/material.dart';

/// A circular button that is the animated brand icon itself, without the
/// extra plate an image button needs.
class DSBrandIconButtonWidget extends StatelessWidget {
  const DSBrandIconButtonWidget({
    super.key,
    required this.brand,
    required this.onTap,
    this.diameter = 56,
    this.tooltip,
    this.playback = DSLottiePlayback.loop,
    this.color,
    this.onColor,
  });

  /// The artwork's circle fills this share of the Lottie canvas.
  static const _artworkRatio = 394 / 512;

  final DSBrandIcon brand;
  final VoidCallback onTap;

  /// Diameter of the visible circle.
  final double diameter;
  final String? tooltip;
  final DSLottiePlayback playback;

  /// Circle color, the brand primary by default.
  final DSColor? color;

  /// Mark color, the brand on-primary by default.
  final DSColor? onColor;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip ?? brand.name,
      child: SizedBox.square(
        dimension: diameter,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: OverflowBox(
                maxWidth: diameter / _artworkRatio,
                maxHeight: diameter / _artworkRatio,
                child: DSBrandIconWidget(
                  brand: brand,
                  size: diameter / _artworkRatio,
                  playback: playback,
                  color: color,
                  onColor: onColor,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
