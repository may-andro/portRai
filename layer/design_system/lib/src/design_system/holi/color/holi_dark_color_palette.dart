import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Holi Dark Color Palette
/// Inspired by Hindu Festival of Colors during magical evening celebration
/// Celebrates the vibrant nighttime festivities with glowing colors and joyful energy
/// Glowing magentas, luminous yellows, and electric blues for dark theme
class HoliDarkColorPalette implements DSColorPalette {
  const HoliDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Festival Pink - luminous Holi colors in darkness
    primary: DSColor(0xFFF48FB1),
    // Light glowing pink
    onPrimary: DSColor(0xFF880E4F),
    // Dark pink text
    primaryContainer: DSColor(0xFFE91E63),
    // Bright festival magenta container
    onPrimaryContainer: DSColor(0xFFF8BBD9),
    // Light pink text
    primaryFixed: DSColor(0xFFEC407A),
    // Fixed vibrant Holi pink
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE91E63),
    onPrimaryFixedVariant: DSColor(0xFF880E4F),

    // Secondary: Luminous Spring Gold - bright gulal powder glow
    secondary: DSColor(0xFFFFEB3B),
    // Bright luminous yellow
    onSecondary: DSColor(0xFF000000),
    // Black text
    secondaryContainer: DSColor(0xFFFDD835),
    // Golden yellow container
    onSecondaryContainer: DSColor(0xFFFFF9C4),
    // Light yellow text
    secondaryFixed: DSColor(0xFFFFEE58),
    // Fixed pure sunshine yellow
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFFEB3B),
    onSecondaryFixedVariant: DSColor(0xFFF57F17),

    // Tertiary: Glowing Electric Blue - vibrant sky celebration
    tertiary: DSColor(0xFF64B5F6),
    // Light electric blue
    onTertiary: DSColor(0xFF0D47A1),
    // Dark blue text
    tertiaryContainer: DSColor(0xFF2196F3),
    // Electric festival blue container
    onTertiaryContainer: DSColor(0xFFBBDEFB),
    // Light blue text
    tertiaryFixed: DSColor(0xFF42A5F5),
    // Fixed bright electric blue
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF2196F3),
    onTertiaryFixedVariant: DSColor(0xFF0D47A1),

    inversePrimary: DSColor(0xFFE91E63),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing red gulal
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Luminous turmeric orange
    warning: DSColor(0xFFFFB74D),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF9800),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing spring green
    success: DSColor(0xFF81C784),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF4CAF50),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Luminous festival blue
    info: DSColor(0xFF64B5F6),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF2196F3),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF1A0E1A),
    // Very dark background with pink hint
    grey1: DSColor(0xFF211821),
    // Dark surface with warm hint
    grey2: DSColor(0xFF2A222A),
    // Elevated warm surface
    grey3: DSColor(0xFF3A2E3A),
    // Medium dark warm surface
    grey4: DSColor(0xFF4A3E4A),
    // Lighter dark warm surface
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
    surface: DSColor(0xFF1A0E1A),
    // Deep warm dark background
    onSurface: DSColor(0xFFE6DDE6),
    // Light warm text
    surfaceVariant: DSColor(0xFF2A1A2A),
    // Very dark warm tint
    onSurfaceVariant: DSColor(0xFFF48FB1),
    // Light pink text
    surfaceDim: DSColor(0xFF160C16),
    // Darker warm surface
    surfaceBright: DSColor(0xFF2A222A),
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
    inverseSurface: DSColor(0xFFE6DDE6),
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
    surfaceTint: DSColor(0xFFF48FB1), // Light pink tint for dark
  );
}
