import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Carnival Dark Color Palette
/// Inspired by vibrant Carnival celebrations during electrifying night festivities
/// Celebrates the nocturnal magic of street parties, neon lights, and midnight revelry
/// Glowing purples, electric oranges, and luminous golds for dark theme
class CarnivalDarkColorPalette implements DSColorPalette {
  const CarnivalDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Electric Purple - glowing neon for dark backgrounds
    primary: DSColor(0xFFBA68C8),
    // Light vibrant purple
    onPrimary: DSColor(0xFF4A148C),
    // Dark purple text
    primaryContainer: DSColor(0xFF6A1B9A),
    // Deep purple container
    onPrimaryContainer: DSColor(0xFFE1BEE7),
    // Light purple text
    primaryFixed: DSColor(0xFF9C27B0),
    // Fixed bright purple
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF7B1FA2),
    onPrimaryFixedVariant: DSColor(0xFF4A148C),

    // Secondary: Neon Orange - electric festival energy
    secondary: DSColor(0xFFFFAB40),
    // Bright electric orange
    onSecondary: DSColor(0xFFBF360C),
    // Dark orange text
    secondaryContainer: DSColor(0xFFE65100),
    // Vibrant orange container
    onSecondaryContainer: DSColor(0xFFFFE0B2),
    // Light orange text
    secondaryFixed: DSColor(0xFFFF9800),
    // Fixed bright orange
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFF6F00),
    onSecondaryFixedVariant: DSColor(0xFFBF360C),

    // Tertiary: Glowing Gold - luminous party lights
    tertiary: DSColor(0xFFFFD54F),
    // Bright glowing yellow
    onTertiary: DSColor(0xFFFF8F00),
    // Warm orange text
    tertiaryContainer: DSColor(0xFFFFD600),
    // Golden container
    onTertiaryContainer: DSColor(0xFFFFF9C4),
    // Light yellow text
    tertiaryFixed: DSColor(0xFFFFEB3B),
    // Fixed festival yellow
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFDD835),
    onTertiaryFixedVariant: DSColor(0xFFFF8F00),

    inversePrimary: DSColor(0xFF6A1B9A),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Electric red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Neon amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Party green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF388E3C),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Electric blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1976D2),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF100818),
    // Very dark purple background
    grey1: DSColor(0xFF1C1B20),
    // Dark surface with purple hint
    grey2: DSColor(0xFF2A2930),
    // Elevated surface
    grey3: DSColor(0xFF3A3A40),
    // Medium dark surface
    grey4: DSColor(0xFF4A4A50),
    // Lighter dark surface
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
    surface: DSColor(0xFF100818),
    // Deep dark purple background
    onSurface: DSColor(0xFFE6D7EA),
    // Light purple text
    surfaceVariant: DSColor(0xFF1F0A2E),
    // Very dark purple tint
    onSurfaceVariant: DSColor(0xFFBA68C8),
    // Light purple text
    surfaceDim: DSColor(0xFF0A0612),
    // Darker purple surface
    surfaceBright: DSColor(0xFF2A2930),
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
    inverseSurface: DSColor(0xFFE6D7EA),
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
    surfaceTint: DSColor(0xFFBA68C8), // Light purple tint for dark
  );
}
