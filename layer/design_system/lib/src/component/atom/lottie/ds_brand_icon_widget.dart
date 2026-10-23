import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/component/atom/lottie/ds_lottie_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:flutter/material.dart';

/// Brands and links that have an animated icon. To add one, drop its Lottie
/// file in `assets/lottie/`, regenerate the assets and add a value here.
enum DSBrandIcon {
  linkedin(Icons.link_rounded),
  github(Icons.link_rounded),
  resume(Icons.description_rounded),
  website(Icons.language_rounded);

  const DSBrandIcon(this.fallbackIcon);

  final IconData fallbackIcon;

  LottieGenImage get asset {
    switch (this) {
      case DSBrandIcon.linkedin:
        return Assets.lottie.linkedin;
      case DSBrandIcon.github:
        return Assets.lottie.github;
      case DSBrandIcon.resume:
        return Assets.lottie.resume;
      case DSBrandIcon.website:
        return Assets.lottie.website;
    }
  }

  /// Maps a link name such as `LinkedIn` to its brand icon, if there is one.
  static DSBrandIcon? fromName(String name) {
    final normalized = name.trim().toLowerCase();
    for (final brand in values) {
      if (brand.name == normalized) return brand;
    }
    return null;
  }

  /// Paints the circle with [color] and the mark with [onColor], the brand
  /// primary pair by default.
  List<DSLottieColorOverride> overrides(
    BuildContext context, {
    DSColor? color,
    DSColor? onColor,
  }) {
    final circle = color ?? context.colorPalette.brand.primary;
    final mark = onColor ?? context.colorPalette.brand.onPrimary;
    switch (this) {
      case DSBrandIcon.linkedin:
        return [
          DSLottieColorOverride(
            keyPath: const ['circle behind Logo', '**', 'Fill 1'],
            color: circle,
          ),
          for (final layer in const ["'N'", "'I' Dot", "'I' Stick"])
            DSLottieColorOverride(
              keyPath: [layer, '**', 'Fill 1'],
              color: mark,
            ),
        ];
      case DSBrandIcon.github:
        return [
          DSLottieColorOverride(
            keyPath: const ['circle behind Logo', '**', 'Fill 1'],
            color: circle,
          ),
          DSLottieColorOverride(
            keyPath: const ['GitHub Mark', '**', 'Fill 1'],
            color: mark,
          ),
        ];
      case DSBrandIcon.resume:
        return _markOverrides('Document Mark', 'Fill 1', circle, mark);
      case DSBrandIcon.website:
        return _markOverrides('Globe Mark', 'Stroke 1', circle, mark);
    }
  }

  /// Marks drawn on the same circle as the brand logos, colored through the
  /// [paint] item of their [markLayer].
  static List<DSLottieColorOverride> _markOverrides(
    String markLayer,
    String paint,
    DSColor circle,
    DSColor mark,
  ) {
    return [
      DSLottieColorOverride(
        keyPath: const ['circle behind Logo', '**', 'Fill 1'],
        color: circle,
      ),
      DSLottieColorOverride(keyPath: [markLayer, '**', paint], color: mark),
    ];
  }
}

/// An animated brand icon themed with the design system brand colors.
class DSBrandIconWidget extends StatelessWidget {
  const DSBrandIconWidget({
    super.key,
    required this.brand,
    required this.size,
    this.playback = DSLottiePlayback.once,
    this.color,
    this.onColor,
  });

  final DSBrandIcon brand;
  final double size;
  final DSLottiePlayback playback;

  /// Circle color, the brand primary by default.
  final DSColor? color;

  /// Mark color, the brand on-primary by default.
  final DSColor? onColor;

  @override
  Widget build(BuildContext context) {
    return DSLottieWidget(
      asset: brand.asset,
      size: size,
      playback: playback,
      colorOverrides: brand.overrides(context, color: color, onColor: onColor),
      fallback: Icon(
        brand.fallbackIcon,
        size: size,
        color: (color ?? context.colorPalette.brand.primary).color,
      ),
    );
  }
}
