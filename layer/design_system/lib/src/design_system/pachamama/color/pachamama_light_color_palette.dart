import 'package:design_system/src/foundation/foundation.dart';

/// Pachamama Light Color Palette
/// Inspired by Andean Mother Earth festival during bright mountain day
/// Celebrates earth goddess, harvest abundance, and deep connection to nature
/// Earthy browns, vibrant greens, and golden harvests for light theme
class PachamamaLightColorPalette implements DSColorPalette {
  const PachamamaLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Sacred Earth Brown - representing Mother Earth and grounding
    primary: DSColor(0xFF5D4037),
    // Deep sacred earth brown
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFD7CCC8),
    // Light earth tone
    onPrimaryContainer: DSColor(0xFF3E2723),
    primaryFixed: DSColor(0xFF795548),
    // Rich earth brown
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF6D4C41),
    onPrimaryFixedVariant: DSColor(0xFF3E2723),

    // Secondary: Sacred Green - representing fertility and life force
    secondary: DSColor(0xFF2E7D32),
    // Deep sacred green
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFC8E6C9),
    // Light sacred green
    onSecondaryContainer: DSColor(0xFF1B5E20),
    secondaryFixed: DSColor(0xFF4CAF50),
    // Vibrant life green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF388E3C),
    onSecondaryFixedVariant: DSColor(0xFF1B5E20),

    // Tertiary: Harvest Gold - representing abundance and prosperity
    tertiary: DSColor(0xFFFF8F00),
    // Bright harvest gold
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFE0B2),
    // Light golden yellow
    onTertiaryContainer: DSColor(0xFFE65100),
    tertiaryFixed: DSColor(0xFFFFA000),
    // Pure harvest gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFF8F00),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFFBCAAA4),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Clay red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Corn amber
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Earth green
    success: DSColor(0xFF4CAF50),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Mountain blue
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
    surface: DSColor(0xFFFCFAF8),
    // Warm white with earth tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFF5F1ED),
    // Very light earth tint
    onSurfaceVariant: DSColor(0xFF5D4037),
    surfaceDim: DSColor(0xFFF0EDE8),
    // Dimmed earth surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFBF8F5),
    surfaceContainer: DSColor(0xFFF5F1ED),
    surfaceContainerHigh: DSColor(0xFFEFEAE5),
    surfaceContainerHighest: DSColor(0xFFE9E3DD),
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
    surfaceTint: DSColor(0xFF5D4037), // Primary earth brown tint
  );
}
