import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Diwali Dark Color Palette
/// Inspired by Hindu Festival of Lights during luminous night celebrations
/// Celebrates the triumph of light piercing through darkness with glowing diyas
/// Luminous golds, glowing purples, and radiant oranges for dark theme
class DiwaliDarkColorPalette implements DSColorPalette {
  const DiwaliDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Gold - luminous divine light piercing darkness
    primary: DSColor(0xFFFFCC02),
    // Bright glowing gold
    onPrimary: DSColor(0xFFE65100),
    // Deep orange text
    primaryContainer: DSColor(0xFFFF8F00),
    // Rich golden container
    onPrimaryContainer: DSColor(0xFFFFE0B2),
    // Light golden text
    primaryFixed: DSColor(0xFFFFC107),
    // Fixed bright festival gold
    onPrimaryFixed: DSColor(0xFF000000),
    primaryFixedDim: DSColor(0xFFFFB300),
    onPrimaryFixedVariant: DSColor(0xFFE65100),

    // Secondary: Luminous Purple - spiritual glow in darkness
    secondary: DSColor(0xFFBA68C8),
    // Light luminous purple
    onSecondary: DSColor(0xFF4A148C),
    // Dark purple text
    secondaryContainer: DSColor(0xFF6A1B9A),
    // Deep purple container
    onSecondaryContainer: DSColor(0xFFE1BEE7),
    // Light purple text
    secondaryFixed: DSColor(0xFF9C27B0),
    // Fixed bright purple
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF7B1FA2),
    onSecondaryFixedVariant: DSColor(0xFF4A148C),

    // Tertiary: Radiant Orange - glowing diya flames
    tertiary: DSColor(0xFFFFAB40),
    // Bright radiant orange
    onTertiary: DSColor(0xFFBF360C),
    // Dark orange text
    tertiaryContainer: DSColor(0xFFE65100),
    // Vibrant orange container
    onTertiaryContainer: DSColor(0xFFFFCCBC),
    // Light coral text
    tertiaryFixed: DSColor(0xFFFF5722),
    // Fixed bright sacred orange
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFFE64A19),
    onTertiaryFixedVariant: DSColor(0xFFBF360C),

    inversePrimary: DSColor(0xFFFF8F00),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing sacred red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Luminous saffron
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing prosperity green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF2E7D32),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Divine luminous blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1976D2),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF1A1408),
    // Very dark warm background with golden hint
    grey1: DSColor(0xFF211C0A),
    // Dark surface with warm golden hint
    grey2: DSColor(0xFF2A250F),
    // Elevated warm surface
    grey3: DSColor(0xFF3A3318),
    // Medium dark warm surface
    grey4: DSColor(0xFF4A4122),
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
    surface: DSColor(0xFF1A1408),
    // Deep warm dark background
    onSurface: DSColor(0xFFE6DDD0),
    // Light warm golden text
    surfaceVariant: DSColor(0xFF2A1F05),
    // Very dark golden tint
    onSurfaceVariant: DSColor(0xFFFFCC02),
    // Bright golden text
    surfaceDim: DSColor(0xFF161202),
    // Darker golden surface
    surfaceBright: DSColor(0xFF2A250F),
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
    inverseSurface: DSColor(0xFFE6DDD0),
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
    surfaceTint: DSColor(0xFFFFCC02), // Bright gold tint for dark
  );
}
