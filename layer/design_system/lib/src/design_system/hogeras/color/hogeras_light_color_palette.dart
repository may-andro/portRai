import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Hogeras Light Color Palette
/// Inspired by Spanish Las Hogueras de San Juan during bright summer day
/// Celebrates Mediterranean coastal summer, bonfires, and sun-soaked festivities
/// Warm fire colors, Mediterranean blues, and golden sunshine for light theme
class HogerasLightColorPalette implements DSColorPalette {
  const HogerasLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Mediterranean Fire Red - passionate bonfire flames
    primary: DSColor(0xFFD32F2F),
    // Deep passionate red
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFFFCDD2),
    // Light fire red
    onPrimaryContainer: DSColor(0xFFB71C1C),
    primaryFixed: DSColor(0xFFE53935),
    // Vibrant bonfire red
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFD32F2F),
    onPrimaryFixedVariant: DSColor(0xFFB71C1C),

    // Secondary: Mediterranean Blue - coastal waters and summer sky
    secondary: DSColor(0xFF1976D2),
    // Deep Mediterranean blue
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFBBDEFB),
    // Light coastal blue
    onSecondaryContainer: DSColor(0xFF0D47A1),
    secondaryFixed: DSColor(0xFF2196F3),
    // Bright Mediterranean blue
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF1976D2),
    onSecondaryFixedVariant: DSColor(0xFF0D47A1),

    // Tertiary: Spanish Sun Gold - radiant summer sunshine
    tertiary: DSColor(0xFFFFB300),
    // Bright Spanish gold
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFE082),
    // Light sunshine yellow
    onTertiaryContainer: DSColor(0xFFFF8F00),
    tertiaryFixed: DSColor(0xFFFFC107),
    // Pure Spanish sun
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFFB300),
    onTertiaryFixedVariant: DSColor(0xFFFF8F00),

    inversePrimary: DSColor(0xFFEF9A9A),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Intense flame red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Sunset orange
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Mediterranean green
    success: DSColor(0xFF388E3C),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Coastal blue
    info: DSColor(0xFF1976D2),
    onInfo: DSColor(0xFFFFFFFF),
    infoContainer: DSColor(0xFFBBDEFB),
    onInfoContainer: DSColor(0xFF0D47A1),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFFFFFFFF),
    grey1: DSColor(0xFFF5F5F5),
    // Very light grey
    grey2: DSColor(0xFFEEEEEE),
    // Light grey
    grey3: DSColor(0xFFE0E0E0),
    // Light medium grey
    grey4: DSColor(0xFFBDBDBD),
    // Medium grey
    grey5: DSColor(0xFF9E9E9E),
    // True grey
    grey6: DSColor(0xFF757575),
    // Dark medium grey
    grey7: DSColor(0xFF616161),
    // Dark grey
    grey8: DSColor(0xFF424242),
    // Very dark grey
    grey9: DSColor(0xFF303030),
    // Almost black
    grey10: DSColor(0xFF212121),
    // Near black
    black: DSColor(0xFF000000),
  );

  @override
  SurfaceColorScheme get surface => const SurfaceColorScheme(
    surface: DSColor(0xFFFFFDF9),
    // Warm white with golden tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFFFF8F0),
    // Very light golden tint
    onSurfaceVariant: DSColor(0xFFD32F2F),
    surfaceDim: DSColor(0xFFFFF4E6),
    // Dimmed golden surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFFFCF7),
    surfaceContainer: DSColor(0xFFFFF8F0),
    surfaceContainerHigh: DSColor(0xFFFFF3E0),
    surfaceContainerHighest: DSColor(0xFFFFEFCC),
    inverseSurface: DSColor(0xFF313033),
    onInverseSurface: DSColor(0xFFF4EFF4),
    inverseOnSurface: DSColor(0xFF313033),
  );

  @override
  OutlineColorScheme get outline => const OutlineColorScheme(
    outline: DSColor(0xFF79747E), // Neutral outline
    outlineVariant: DSColor(0xFFCAC4D0), // Light outline
  );

  @override
  UtilityColorScheme get utility => const UtilityColorScheme(
    shadow: DSColor(0xFF000000),
    scrim: DSColor(0xFF000000),
    surfaceTint: DSColor(0xFFD32F2F), // Primary red tint
  );
}
