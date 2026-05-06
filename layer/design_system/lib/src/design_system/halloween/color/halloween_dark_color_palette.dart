import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Halloween Dark Color Palette
/// Inspired by spooky Halloween celebration during haunting night
/// Celebrates the eerie atmosphere of midnight frights and ghostly encounters
/// Glowing oranges, mystical purples, and haunting blacks for dark theme
class HalloweenDarkColorPalette implements DSColorPalette {
  const HalloweenDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Pumpkin - eerie jack-o'-lantern glow in darkness
    primary: DSColor(0xFFFFAB40),
    // Bright glowing orange
    onPrimary: DSColor(0xFFBF360C),
    // Dark orange text
    primaryContainer: DSColor(0xFFE65100),
    // Deep pumpkin container
    onPrimaryContainer: DSColor(0xFFFFCCBC),
    // Light orange text
    primaryFixed: DSColor(0xFFFF5722),
    // Fixed bright Halloween orange
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE64A19),
    onPrimaryFixedVariant: DSColor(0xFFBF360C),

    // Secondary: Mystical Purple - haunting witch magic in darkness
    secondary: DSColor(0xFFBA68C8),
    // Light mystical purple
    onSecondary: DSColor(0xFF2E0051),
    // Dark purple text
    secondaryContainer: DSColor(0xFF4A148C),
    // Deep witch purple container
    onSecondaryContainer: DSColor(0xFFE1BEE7),
    // Light purple text
    secondaryFixed: DSColor(0xFF6A1B9A),
    // Fixed bright witch purple
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF4A148C),
    onSecondaryFixedVariant: DSColor(0xFF2E0051),

    // Tertiary: Ghostly Gold - ethereal candlelight glow
    tertiary: DSColor(0xFFFFCC02),
    // Bright ghostly gold
    onTertiary: DSColor(0xFFE65100),
    // Dark orange text
    tertiaryContainer: DSColor(0xFFFF8F00),
    // Rich autumn gold container
    onTertiaryContainer: DSColor(0xFFFFE0B2),
    // Light golden text
    tertiaryFixed: DSColor(0xFFFFA000),
    // Fixed bright autumn gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFF8F00),
    onTertiaryFixedVariant: DSColor(0xFFE65100),

    inversePrimary: DSColor(0xFFE65100),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing blood red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Eerie amber
    warning: DSColor(0xFFFFB74D),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF6F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Phantom green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF2E7D32),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Ghostly blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1565C0),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF0A0A0A),
    // Very dark spooky background
    grey1: DSColor(0xFF1A1A1A),
    // Dark haunted surface
    grey2: DSColor(0xFF2A2A2A),
    // Elevated spooky surface
    grey3: DSColor(0xFF3A3A3A),
    // Medium dark haunted surface
    grey4: DSColor(0xFF4A4A4A),
    // Lighter dark spooky surface
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
    surface: DSColor(0xFF0A0A0A),
    // Deep spooky dark background
    onSurface: DSColor(0xFFE6DDD7),
    // Light eerie text
    surfaceVariant: DSColor(0xFF1F0A05),
    // Very dark orange tint
    onSurfaceVariant: DSColor(0xFFFFAB40),
    // Bright orange text
    surfaceDim: DSColor(0xFF070707),
    // Darker haunted surface
    surfaceBright: DSColor(0xFF2A2A2A),
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
    inverseSurface: DSColor(0xFFE6DDD7),
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
    surfaceTint: DSColor(0xFFFFAB40), // Bright orange tint for dark
  );
}
