import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/component/atom/lottie/ds_lottie_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// Brands that have an animated icon. To add one, drop its Lottie file in
/// `assets/lottie/`, regenerate the assets and add a value here.
enum DSBrandIcon {
  linkedin(Icons.link_rounded),
  github(Icons.link_rounded);

  const DSBrandIcon(this.fallbackIcon);

  final IconData fallbackIcon;

  LottieGenImage get asset {
    switch (this) {
      case DSBrandIcon.linkedin:
        return Assets.lottie.linkedin;
      case DSBrandIcon.github:
        return Assets.lottie.github;
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

  List<DSLottieColorOverride> overrides(BuildContext context) {
    final brandColors = context.colorPalette.brand;
    switch (this) {
      case DSBrandIcon.linkedin:
        return [
          DSLottieColorOverride(
            keyPath: const ['circle behind Logo', '**', 'Fill 1'],
            color: brandColors.primary,
          ),
          for (final layer in const ["'N'", "'I' Dot", "'I' Stick"])
            DSLottieColorOverride(
              keyPath: [layer, '**', 'Fill 1'],
              color: brandColors.onPrimary,
            ),
        ];
      case DSBrandIcon.github:
        return [
          DSLottieColorOverride(
            keyPath: const ['circle behind Logo', '**', 'Fill 1'],
            color: brandColors.primary,
          ),
          DSLottieColorOverride(
            keyPath: const ['GitHub Mark', '**', 'Fill 1'],
            color: brandColors.onPrimary,
          ),
        ];
    }
  }
}

/// An animated brand icon themed with the design system brand colors.
class DSBrandIconWidget extends StatelessWidget {
  const DSBrandIconWidget({
    super.key,
    required this.brand,
    required this.size,
    this.playback = DSLottiePlayback.once,
  });

  final DSBrandIcon brand;
  final double size;
  final DSLottiePlayback playback;

  @override
  Widget build(BuildContext context) {
    return DSLottieWidget(
      asset: brand.asset,
      size: size,
      playback: playback,
      colorOverrides: brand.overrides(context),
      fallback: Icon(
        brand.fallbackIcon,
        size: size,
        color: context.colorPalette.brand.primary.color,
      ),
    );
  }
}
