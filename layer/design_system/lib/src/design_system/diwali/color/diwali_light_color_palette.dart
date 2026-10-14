import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Diwali Light Color Palette
/// Inspired by Hindu Festival of Lights during bright celebration day
/// Celebrates the victory of light over darkness, good over evil
/// Warm golds, royal purples, and vibrant oranges for light theme
class DiwaliLightColorPalette implements DSColorPalette {
  const DiwaliLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Divine Gold (सोना) - representing prosperity and divine light
    primary: DSColor(0xFFDB7B00),
    // Rich divine gold
    onPrimary: DSColor(0xFF000000),
    primaryContainer: DSColor(0xFFFFE0B2),
    // Light golden yellow
    onPrimaryContainer: DSColor(0xFFB33F00),
    primaryFixed: DSColor(0xFFFFC107),
    // Bright festival gold
    onPrimaryFixed: DSColor(0xFF000000),
    primaryFixedDim: DSColor(0xFFFFB300),
    onPrimaryFixedVariant: DSColor(0xFF943400),

    // Secondary: Royal Purple (बैंगनी) - representing spirituality and wisdom
    secondary: DSColor(0xFF6A1B9A),
    // Deep royal purple
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFE1BEE7),
    // Light lavender
    onSecondaryContainer: DSColor(0xFF4A148C),
    secondaryFixed: DSColor(0xFF9C27B0),
    // Bright purple
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF7B1FA2),
    onSecondaryFixedVariant: DSColor(0xFFE5D4F9),

    // Tertiary: Rangoli Magenta - festive pink of rangoli and celebration
    tertiary: DSColor(0xFFE60073),
    // Vibrant sacred orange
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFBCDE),
    // Light coral
    onTertiaryContainer: DSColor(0xFFAC0B5C),
    tertiaryFixed: DSColor(0xFFFF2291),
    // Bright sacred orange
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFE61980),
    onTertiaryFixedVariant: DSColor(0xFF000000),

    inversePrimary: DSColor(0xFFFFCC02),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Sacred red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Festival saffron
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFB33F00),

    // Success: Prosperity green
    success: DSColor(0xFF2E7D32),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Divine blue
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
    surface: DSColor(0xFFFFFDF7),
    // Warm white with golden tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFFFF8E1),
    // Very light golden tint
    onSurfaceVariant: DSColor(0xFFA85E00),
    surfaceDim: DSColor(0xFFFFF4E6),
    // Dimmed golden surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFFFEFA),
    surfaceContainer: DSColor(0xFFFFF8E1),
    surfaceContainerHigh: DSColor(0xFFFFF3D6),
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
    surfaceTint: DSColor(0xFFFF8F00), // Primary gold tint
  );
}
