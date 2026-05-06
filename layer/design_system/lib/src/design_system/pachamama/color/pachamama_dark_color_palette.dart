import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Pachamama Dark Color Palette
/// Inspired by Andean Mother Earth festival during sacred night ceremonies
/// Celebrates the mystical connection to earth goddess under starlit Andean skies
/// Glowing earths, luminous greens, and warm harvest golds for dark theme
class PachamamaDarkColorPalette implements DSColorPalette {
  const PachamamaDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Sacred Earth - warm earth mother glow in darkness
    primary: DSColor(0xFFBCAAA4),
    // Light warm earth brown
    onPrimary: DSColor(0xFF3E2723),
    // Dark brown text
    primaryContainer: DSColor(0xFF5D4037),
    // Deep sacred earth brown container
    onPrimaryContainer: DSColor(0xFFD7CCC8),
    // Light earth text
    primaryFixed: DSColor(0xFF795548),
    // Fixed rich earth brown
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF6D4C41),
    onPrimaryFixedVariant: DSColor(0xFF3E2723),

    // Secondary: Luminous Life Force - glowing sacred green energy
    secondary: DSColor(0xFF81C784),
    // Light sacred green
    onSecondary: DSColor(0xFF1B5E20),
    // Dark green text
    secondaryContainer: DSColor(0xFF2E7D32),
    // Deep sacred green container
    onSecondaryContainer: DSColor(0xFFC8E6C9),
    // Light green text
    secondaryFixed: DSColor(0xFF4CAF50),
    // Fixed vibrant life green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF388E3C),
    onSecondaryFixedVariant: DSColor(0xFF1B5E20),

    // Tertiary: Glowing Harvest - warm abundance in moonlight
    tertiary: DSColor(0xFFFFCC02),
    // Bright glowing harvest gold
    onTertiary: DSColor(0xFFE65100),
    // Dark orange text
    tertiaryContainer: DSColor(0xFFFF8F00),
    // Bright harvest gold container
    onTertiaryContainer: DSColor(0xFFFFE0B2),
    // Light golden text
    tertiaryFixed: DSColor(0xFFFFA000),
    // Fixed pure harvest gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFF8F00),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFF5D4037),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing clay red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Luminous corn amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing earth green
    success: DSColor(0xFF81C784),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF4CAF50),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Starlit mountain blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1976D2),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF1A1611),
    // Very dark earth background
    grey1: DSColor(0xFF211E19),
    // Dark surface with earth hint
    grey2: DSColor(0xFF2A2622),
    // Elevated earth surface
    grey3: DSColor(0xFF3A342D),
    // Medium dark earth surface
    grey4: DSColor(0xFF4A4238),
    // Lighter dark earth surface
    grey5: DSColor(0xFF616161),
    // Mid grey
    grey6: DSColor(0xFF757575),
    // Light medium grey
    grey7: DSColor(0xFF9E9E9E),
    // Light grey
    grey8: DSColor(0xFFBDBDBD),
    // Very light grey
    grey9: DSColor(0xFFE0E0E0),
    // Near white
    grey10: DSColor(0xFFF5F5F5),
    // Almost white
    black: DSColor(0xFFFFFFFF), // White text on dark
  );

  @override
  SurfaceColorScheme get surface => const SurfaceColorScheme(
    surface: DSColor(0xFF1A1611),
    // Deep earth dark background
    onSurface: DSColor(0xFFE9E3DD),
    // Light earth text
    surfaceVariant: DSColor(0xFF2A211A),
    // Very dark earth tint
    onSurfaceVariant: DSColor(0xFFBCAAA4),
    // Light earth text
    surfaceDim: DSColor(0xFF16130E),
    // Darker earth surface
    surfaceBright: DSColor(0xFF2A2622),
    // Brighter dark surface
    surfaceContainerLowest: DSColor(0xFF0F0F0F),
    // Deepest container
    surfaceContainerLow: DSColor(0xFF1A1A1A),
    // Low elevation
    surfaceContainer: DSColor(0xFF242424),
    // Standard container
    surfaceContainerHigh: DSColor(0xFF2E2E2E),
    // High elevation
    surfaceContainerHighest: DSColor(0xFF383838),
    // Highest elevation
    inverseSurface: DSColor(0xFFE9E3DD),
    // Light inverse
    onInverseSurface: DSColor(0xFF313033),
    // Dark text on light
    inverseOnSurface: DSColor(0xFFF4EFF4), // Light text
  );

  @override
  OutlineColorScheme get outline => const OutlineColorScheme(
    outline: DSColor(0xFF938F99), // Lighter neutral outline for dark
    outlineVariant: DSColor(0xFF49454F), // Dark outline variant
  );

  @override
  UtilityColorScheme get utility => const UtilityColorScheme(
    shadow: DSColor(0xFF000000),
    scrim: DSColor(0xFF000000),
    surfaceTint: DSColor(0xFFBCAAA4), // Light earth tint for dark
  );
}
