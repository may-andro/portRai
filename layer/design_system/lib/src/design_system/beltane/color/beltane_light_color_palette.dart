import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Beltane Light Color Palette
/// Inspired by Celtic May Day festival during bright spring day
/// Celebrates new growth, fertility, and the awakening of nature in sunlight
/// Fresh greens, earth tones, and golden warmth for light theme
class BeltaneLightColorPalette implements DSColorPalette {
  const BeltaneLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Fresh Spring Green
    primary: DSColor(0xFF2E7D32), // Deep forest green
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFA5D6A7), // Light spring green
    onPrimaryContainer: DSColor(0xFF1B5E20),
    primaryFixed: DSColor(0xFF4CAF50), // Vibrant green
    onPrimaryFixed: DSColor(0xFF000000),
    primaryFixedDim: DSColor(0xFF388E3C),
    onPrimaryFixedVariant: DSColor(0xFF1B5E20),

    // Secondary: Earth Brown
    secondary: DSColor(0xFF5D4037), // Rich earth brown
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFD7CCC8), // Light earth tone
    onSecondaryContainer: DSColor(0xFF3E2723),
    secondaryFixed: DSColor(0xFF795548), // Warm brown
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF6D4C41),
    onSecondaryFixedVariant: DSColor(0xFF3E2723),

    // Tertiary: Golden Sun
    tertiary: DSColor(0xFFFF8F00), // Bright golden amber
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFE0B2), // Light golden yellow
    onTertiaryContainer: DSColor(0xFFE65100),
    tertiaryFixed: DSColor(0xFFFFC107), // Pure gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFFB300),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFF81C784),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Deep red earth
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Autumn orange
    warning: DSColor(0xFFFF6F00),
    onWarning: DSColor(0xFFFFFFFF),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: New leaf green
    success: DSColor(0xFF388E3C),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Sky blue
    info: DSColor(0xFF1976D2),
    onInfo: DSColor(0xFFFFFFFF),
    infoContainer: DSColor(0xFFBBDEFB),
    onInfoContainer: DSColor(0xFF0D47A1),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFFFFFFFF),
    grey1: DSColor(0xFFF5F5F5), // Very light grey
    grey2: DSColor(0xFFEEEEEE), // Light grey
    grey3: DSColor(0xFFE0E0E0), // Light medium grey
    grey4: DSColor(0xFFBDBDBD), // Medium grey
    grey5: DSColor(0xFF9E9E9E), // True grey
    grey6: DSColor(0xFF757575), // Dark medium grey
    grey7: DSColor(0xFF616161), // Dark grey
    grey8: DSColor(0xFF424242), // Very dark grey
    grey9: DSColor(0xFF303030), // Almost black
    grey10: DSColor(0xFF212121), // Near black
    black: DSColor(0xFF000000),
  );

  @override
  SurfaceColorScheme get surface => const SurfaceColorScheme(
    surface: DSColor(0xFFFAFAFA), // Soft white
    onSurface: DSColor(0xFF212121),
    surfaceVariant: DSColor(0xFFF1F8E9), // Very light green tint
    onSurfaceVariant: DSColor(0xFF2E7D32),
    surfaceDim: DSColor(0xFFE8F5E8), // Dimmed green surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFF8F9FA),
    surfaceContainer: DSColor(0xFFF1F3F4),
    surfaceContainerHigh: DSColor(0xFFE8EAED),
    surfaceContainerHighest: DSColor(0xFFE1E3E1),
    inverseSurface: DSColor(0xFF2F312F),
    onInverseSurface: DSColor(0xFFF0F1EC),
    inverseOnSurface: DSColor(0xFF2F312F),
  );

  @override
  OutlineColorScheme get outline => const OutlineColorScheme(
    outline: DSColor(0xFF79747E), // Neutral outline
    outlineVariant: DSColor(0xFFC4C7C5), // Light outline
  );

  @override
  UtilityColorScheme get utility => const UtilityColorScheme(
    shadow: DSColor(0xFF000000),
    scrim: DSColor(0xFF000000),
    surfaceTint: DSColor(0xFF2E7D32), // Primary green tint
  );
}
