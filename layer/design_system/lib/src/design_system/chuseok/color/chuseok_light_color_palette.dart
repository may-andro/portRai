import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Chuseok Light Color Palette
/// Inspired by Korean harvest festival during bright autumn day
/// Celebrates family, gratitude, and the golden autumn harvest
/// Warm earth tones, traditional Korean colors, and harvest golds for light theme
class ChuseokLightColorPalette implements DSColorPalette {
  const ChuseokLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Traditional Korean Red (단청 빨강)
    primary: DSColor(0xFFD32F2F),
    // Deep traditional red
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFFFCDD2),
    // Light traditional red
    onPrimaryContainer: DSColor(0xFFB71C1C),
    primaryFixed: DSColor(0xFFE53935),
    // Vibrant Korean red
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFD32F2F),
    onPrimaryFixedVariant: DSColor(0xFFB71C1C),

    // Secondary: Harvest Gold (황금색)
    secondary: DSColor(0xFFFF8F00),
    // Rich harvest gold
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFFFE0B2),
    // Light golden yellow
    onSecondaryContainer: DSColor(0xFFE65100),
    secondaryFixed: DSColor(0xFFFFA000),
    // Bright harvest gold
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFF8F00),
    onSecondaryFixedVariant: DSColor(0xFFE65100),

    // Tertiary: Traditional Blue (단청 파랑)
    tertiary: DSColor(0xFF1976D2),
    // Traditional Korean blue
    onTertiary: DSColor(0xFFFFFFFF),
    tertiaryContainer: DSColor(0xFFBBDEFB),
    // Light traditional blue
    onTertiaryContainer: DSColor(0xFF0D47A1),
    tertiaryFixed: DSColor(0xFF2196F3),
    // Bright Korean blue
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF1976D2),
    onTertiaryFixedVariant: DSColor(0xFF0D47A1),

    inversePrimary: DSColor(0xFFEF9A9A),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Deep autumn red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Persimmon orange
    warning: DSColor(0xFFFF6F00),
    onWarning: DSColor(0xFFFFFFFF),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Pine green
    success: DSColor(0xFF2E7D32),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Traditional blue
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
    surface: DSColor(0xFFFFFBF8),
    // Warm white with subtle gold tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFFFF3E0),
    // Very light golden tint
    onSurfaceVariant: DSColor(0xFFD32F2F),
    surfaceDim: DSColor(0xFFFFF8F0),
    // Dimmed golden surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFFFDF9),
    surfaceContainer: DSColor(0xFFFFF8F0),
    surfaceContainerHigh: DSColor(0xFFFFF3E0),
    surfaceContainerHighest: DSColor(0xFFFFEDD5),
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
