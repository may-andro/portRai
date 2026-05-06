import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Holi Light Color Palette
/// Inspired by Hindu Festival of Colors during bright spring celebration
/// Celebrates vibrant colors, spring joy, and the triumph of good over evil
/// Magenta pinks, sunshine yellows, and electric blues for light theme
class HoliLightColorPalette implements DSColorPalette {
  const HoliLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Festival Magenta - vibrant Holi pink representing joy and celebration
    primary: DSColor(0xFFE91E63),
    // Bright festival magenta
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFF8BBD9),
    // Light festival pink
    onPrimaryContainer: DSColor(0xFF880E4F),
    primaryFixed: DSColor(0xFFEC407A),
    // Vibrant Holi pink
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE91E63),
    onPrimaryFixedVariant: DSColor(0xFF880E4F),

    // Secondary: Spring Yellow - bright sunshine representing new beginnings
    secondary: DSColor(0xFFFFEB3B),
    // Bright spring yellow
    onSecondary: DSColor(0xFF000000),
    secondaryContainer: DSColor(0xFFFFF9C4),
    // Light sunshine yellow
    onSecondaryContainer: DSColor(0xFFF57F17),
    secondaryFixed: DSColor(0xFFFFEE58),
    // Pure sunshine yellow
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFFEB3B),
    onSecondaryFixedVariant: DSColor(0xFFF57F17),

    // Tertiary: Electric Blue - vibrant sky blue representing freedom and happiness
    tertiary: DSColor(0xFF2196F3),
    // Electric festival blue
    onTertiary: DSColor(0xFFFFFFFF),
    tertiaryContainer: DSColor(0xFFBBDEFB),
    // Light sky blue
    onTertiaryContainer: DSColor(0xFF0D47A1),
    tertiaryFixed: DSColor(0xFF42A5F5),
    // Bright electric blue
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF2196F3),
    onTertiaryFixedVariant: DSColor(0xFF0D47A1),

    inversePrimary: DSColor(0xFFE1BEE7),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Vibrant red gulal
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Orange turmeric
    warning: DSColor(0xFFFF9800),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Green spring
    success: DSColor(0xFF4CAF50),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Festival blue
    info: DSColor(0xFF2196F3),
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
    surface: DSColor(0xFFFFFBFE),
    // Warm white with pink tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFFFF0F5),
    // Very light pink tint
    onSurfaceVariant: DSColor(0xFFE91E63),
    surfaceDim: DSColor(0xFFFFE8F0),
    // Dimmed pink surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFFFAFC),
    surfaceContainer: DSColor(0xFFFFF5F8),
    surfaceContainerHigh: DSColor(0xFFFFF0F5),
    surfaceContainerHighest: DSColor(0xFFFFEBF2),
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
    surfaceTint: DSColor(0xFFE91E63), // Primary magenta tint
  );
}
