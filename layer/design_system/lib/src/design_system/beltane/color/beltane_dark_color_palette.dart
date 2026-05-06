import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Beltane Dark Color Palette
/// Inspired by Celtic May Day festival during mystical forest night
/// Celebrates the nocturnal magic of nature - moonlit clearings and glowing embers
/// Muted greens, warm earth tones, and golden embers for dark theme
class BeltaneDarkColorPalette implements DSColorPalette {
  const BeltaneDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Moonlit Green - softer, more muted for dark backgrounds
    primary: DSColor(0xFF81C784), // Light spring green for dark theme
    onPrimary: DSColor(0xFF1B5E20), // Dark forest green text
    primaryContainer: DSColor(0xFF2E7D32), // Deep forest green container
    onPrimaryContainer: DSColor(0xFFA5D6A7), // Light green text
    primaryFixed: DSColor(0xFF4CAF50), // Fixed vibrant green
    onPrimaryFixed: DSColor(0xFF000000),
    primaryFixedDim: DSColor(0xFF388E3C),
    onPrimaryFixedVariant: DSColor(0xFF1B5E20),

    // Secondary: Night Earth - warmer browns for cozy dark feel
    secondary: DSColor(0xFFBCAAA4), // Light warm brown
    onSecondary: DSColor(0xFF3E2723), // Dark brown text
    secondaryContainer: DSColor(0xFF5D4037), // Rich earth brown container
    onSecondaryContainer: DSColor(0xFFD7CCC8), // Light earth tone text
    secondaryFixed: DSColor(0xFF795548), // Fixed warm brown
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF6D4C41),
    onSecondaryFixedVariant: DSColor(0xFF3E2723),

    // Tertiary: Warm Ember - golden tones for dark environments
    tertiary: DSColor(0xFFFFCC02), // Bright warm gold
    onTertiary: DSColor(0xFF3E2723), // Dark brown text
    tertiaryContainer: DSColor(0xFFFF8F00), // Golden amber container
    onTertiaryContainer: DSColor(0xFFFFE0B2), // Light golden text
    tertiaryFixed: DSColor(0xFFFFC107), // Fixed pure gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFFB300),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFF2E7D32),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Warm red ember
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFF3E2723),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Golden flame
    warning: DSColor(0xFFFFB74D),
    onWarning: DSColor(0xFF3E2723),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Forest glow
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF388E3C),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Moonlight blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1976D2),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF121212), // Very dark background
    grey1: DSColor(0xFF1E1E1E), // Dark surface
    grey2: DSColor(0xFF2D2D2D), // Elevated surface
    grey3: DSColor(0xFF3A3A3A), // Medium dark surface
    grey4: DSColor(0xFF4A4A4A), // Lighter dark surface
    grey5: DSColor(0xFF616161), // Mid grey
    grey6: DSColor(0xFF757575), // Light medium grey
    grey7: DSColor(0xFF9E9E9E), // Light grey
    grey8: DSColor(0xFFBDBDBD), // Very light grey
    grey9: DSColor(0xFFE0E0E0), // Near white
    grey10: DSColor(0xFFF5F5F5), // Almost white
    black: DSColor(0xFFFFFFFF), // White text on dark
  );

  @override
  SurfaceColorScheme get surface => const SurfaceColorScheme(
    surface: DSColor(0xFF121212), // Deep dark background
    onSurface: DSColor(0xFFE0E0E0), // Light text
    surfaceVariant: DSColor(0xFF1A2C1A), // Very dark green tint
    onSurfaceVariant: DSColor(0xFF81C784), // Light green text
    surfaceDim: DSColor(0xFF0F1B0F), // Darker green surface
    surfaceBright: DSColor(0xFF2D2D2D), // Brighter dark surface
    surfaceContainerLowest: DSColor(0xFF0F0F0F), // Deepest container
    surfaceContainerLow: DSColor(0xFF1A1A1A), // Low elevation
    surfaceContainer: DSColor(0xFF242424), // Standard container
    surfaceContainerHigh: DSColor(0xFF2E2E2E), // High elevation
    surfaceContainerHighest: DSColor(0xFF383838), // Highest elevation
    inverseSurface: DSColor(0xFFE1E3E1), // Light inverse
    onInverseSurface: DSColor(0xFF2F312F), // Dark text on light
    inverseOnSurface: DSColor(0xFFF0F1EC), // Light text
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
    surfaceTint: DSColor(0xFF81C784), // Light green tint for dark
  );
}
