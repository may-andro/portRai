import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Halloween Light Color Palette
/// Inspired by spooky Halloween celebration during bright autumn day
/// Celebrates playful frights, autumn harvest, and gothic fun
/// Deep oranges, mysterious purples, and classic blacks for light theme
class HalloweenLightColorPalette implements DSColorPalette {
  const HalloweenLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Jack-o'-lantern Orange - classic Halloween pumpkin color
    primary: DSColor(0xFFE65100),
    // Deep pumpkin orange
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFFFCCBC),
    // Light pumpkin
    onPrimaryContainer: DSColor(0xFFBF360C),
    primaryFixed: DSColor(0xFFFF5722),
    // Bright Halloween orange
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE64A19),
    onPrimaryFixedVariant: DSColor(0xFFBF360C),

    // Secondary: Witch Purple - mysterious and magical
    secondary: DSColor(0xFF4A148C),
    // Deep mystical purple
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFE1BEE7),
    // Light mystical purple
    onSecondaryContainer: DSColor(0xFF2E0051),
    secondaryFixed: DSColor(0xFF6A1B9A),
    // Bright witch purple
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF4A148C),
    onSecondaryFixedVariant: DSColor(0xFF2E0051),

    // Tertiary: Autumn Gold - harvest and candlelight
    tertiary: DSColor(0xFFFF8F00),
    // Rich autumn gold
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFE0B2),
    // Light golden yellow
    onTertiaryContainer: DSColor(0xFFE65100),
    tertiaryFixed: DSColor(0xFFFFA000),
    // Bright autumn gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFF8F00),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFFFFAB40),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Blood red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Spooky amber
    warning: DSColor(0xFFFF6F00),
    onWarning: DSColor(0xFFFFFFFF),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Eerie green
    success: DSColor(0xFF2E7D32),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Midnight blue
    info: DSColor(0xFF1565C0),
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
    surface: DSColor(0xFFFFF8F5),
    // Warm white with orange tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFFFF3E0),
    // Very light orange tint
    onSurfaceVariant: DSColor(0xFFE65100),
    surfaceDim: DSColor(0xFFFFF0E6),
    // Dimmed orange surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFFFBF8),
    surfaceContainer: DSColor(0xFFFFF6ED),
    surfaceContainerHigh: DSColor(0xFFFFF1E3),
    surfaceContainerHighest: DSColor(0xFFFFEDD9),
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
    surfaceTint: DSColor(0xFFE65100), // Primary orange tint
  );
}
