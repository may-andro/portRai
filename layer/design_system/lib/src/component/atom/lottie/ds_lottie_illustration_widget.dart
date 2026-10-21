import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/component/atom/lottie/ds_lottie_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// Full-colour Lottie scenes, shown with their original colors. To add one,
/// drop the file in `assets/lottie/`, regenerate the assets and add a value.
enum DSLottieIllustration {
  globalNetwork(800 / 600),
  contactUs(1),
  graduationHat(1),
  heroOrbs(16 / 9),
  heroOrbsMobile(9 / 16),
  pinPulse(1),
  orbit(1),
  globe(1),
  mapPin(1),
  developerRole(1330 / 920),
  recruiterRole(1330 / 920),
  explorerRole(1),
  techStack(1),
  computerWindow(1),
  talentSearch(1),
  signIn(1);

  const DSLottieIllustration(this.aspectRatio);

  final double aspectRatio;

  /// Recolors the scene with the design system palette, by layer name.
  /// Scenes without a mapping keep their original colors.
  List<DSLottieColorOverride> themeOverrides(DSColorPalette palette) {
    DSLottieColorOverride override(List<String> keyPath, DSColor color) {
      return DSLottieColorOverride(keyPath: keyPath, color: color);
    }

    switch (this) {
      case DSLottieIllustration.mapPin:
        return [
          override(const ['Logo', '**'], palette.brand.primary),
          override(const ['logo', '**'], palette.brand.onPrimary),
          override(const ['1', '**'], palette.brand.tertiary),
          override(const ['2', '**'], palette.brand.tertiary),
          override(const ['3', '**'], palette.brand.tertiary),
        ];
      case DSLottieIllustration.globe:
        return [
          override(const [
            'Files',
            'MAp',
            '**',
            'Fill 1',
          ], palette.brand.primary),
          override(const ['Shadow', '**'], palette.brand.tertiary),
          override(const ['Shape Layer 1', '**'], palette.brand.tertiary),
          override(const ['Shape Layer 2', '**'], palette.brand.tertiary),
        ];
      case DSLottieIllustration.graduationHat:
      case DSLottieIllustration.recruiterRole:
        return [
          override(const ['**', 'Accent'], palette.brand.primary),
        ];
      case DSLottieIllustration.globalNetwork:
      case DSLottieIllustration.contactUs:
      case DSLottieIllustration.heroOrbs:
      case DSLottieIllustration.heroOrbsMobile:
      case DSLottieIllustration.pinPulse:
      case DSLottieIllustration.orbit:
      case DSLottieIllustration.developerRole:
      case DSLottieIllustration.explorerRole:
      case DSLottieIllustration.techStack:
      case DSLottieIllustration.computerWindow:
      case DSLottieIllustration.talentSearch:
      case DSLottieIllustration.signIn:
        return const [];
    }
  }

  LottieGenImage get asset {
    switch (this) {
      case DSLottieIllustration.globalNetwork:
        return Assets.lottie.globalNetwork;
      case DSLottieIllustration.contactUs:
        return Assets.lottie.contactUs;
      case DSLottieIllustration.graduationHat:
        return Assets.lottie.graduationHat;
      case DSLottieIllustration.heroOrbs:
        return Assets.lottie.heroOrbs;
      case DSLottieIllustration.heroOrbsMobile:
        return Assets.lottie.heroOrbsMobile;
      case DSLottieIllustration.globe:
        return Assets.lottie.globe;
      case DSLottieIllustration.mapPin:
        return Assets.lottie.mapPin;
      case DSLottieIllustration.orbit:
        return Assets.lottie.orbit;
      case DSLottieIllustration.pinPulse:
        return Assets.lottie.pinPulse;
      case DSLottieIllustration.developerRole:
        return Assets.lottie.developerRole;
      case DSLottieIllustration.recruiterRole:
        return Assets.lottie.recruiterRole;
      case DSLottieIllustration.explorerRole:
        return Assets.lottie.explorerRole;
      case DSLottieIllustration.techStack:
        return Assets.lottie.techStack;
      case DSLottieIllustration.computerWindow:
        return Assets.lottie.computerWindow;
      case DSLottieIllustration.talentSearch:
        return Assets.lottie.talentSearch;
      case DSLottieIllustration.signIn:
        return Assets.lottie.signIn;
    }
  }
}

class DSLottieIllustrationWidget extends StatelessWidget {
  const DSLottieIllustrationWidget({
    super.key,
    required this.illustration,
    required this.width,
    this.playback = DSLottiePlayback.loop,
    this.colorOverrides = const [],
    this.useThemeColors = true,
  });

  final DSLottieIllustration illustration;
  final double width;
  final DSLottiePlayback playback;

  /// Applied after the theme colors, so they win on the same layers.
  final List<DSLottieColorOverride> colorOverrides;

  /// Recolors the scene with the design system palette, see
  /// [DSLottieIllustration.themeOverrides].
  final bool useThemeColors;

  @override
  Widget build(BuildContext context) {
    return DSLottieWidget(
      asset: illustration.asset,
      size: width,
      aspectRatio: illustration.aspectRatio,
      playback: playback,
      colorOverrides: [
        if (useThemeColors)
          ...illustration.themeOverrides(context.colorPalette),
        ...colorOverrides,
      ],
    );
  }
}

/// A faded, optionally greyed-out illustration that fills its parent, meant to
/// sit behind content without competing with it.
class DSLottieBackgroundWidget extends StatelessWidget {
  const DSLottieBackgroundWidget({
    super.key,
    required this.illustration,
    this.opacity = 0.2,
    this.grayscale = false,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.playback = DSLottiePlayback.loop,
    this.colorOverrides = const [],
  });

  static const _grayscaleFilter = ColorFilter.matrix([
    0.2126, 0.7152, 0.0722, 0, 0, //
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ]);

  final DSLottieIllustration illustration;
  final double opacity;
  final bool grayscale;
  final BoxFit fit;
  final Alignment alignment;
  final DSLottiePlayback playback;
  final List<DSLottieColorOverride> colorOverrides;

  @override
  Widget build(BuildContext context) {
    Widget content = FittedBox(
      fit: fit,
      alignment: alignment,
      clipBehavior: Clip.hardEdge,
      child: DSLottieIllustrationWidget(
        illustration: illustration,
        width: 800,
        playback: playback,
        colorOverrides: colorOverrides,
      ),
    );
    if (grayscale) {
      content = ColorFiltered(colorFilter: _grayscaleFilter, child: content);
    }
    return IgnorePointer(
      child: RepaintBoundary(
        child: Opacity(opacity: opacity, child: content),
      ),
    );
  }
}
