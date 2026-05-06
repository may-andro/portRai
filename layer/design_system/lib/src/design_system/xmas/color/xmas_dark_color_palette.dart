import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Christmas Dark Color Palette
/// Inspired by Christmas celebration during cozy winter evening
/// Celebrates the warm glow of holiday lights and fireside gatherings
/// Glowing reds, luminous greens, and warm golds for dark theme
class ChristmasDarkColorPalette implements DSColorPalette {
  const ChristmasDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Christmas Light - warm festive red in cozy darkness
    primary: DSColor(0xFFEF9A9A),
    // Light glowing red
    onPrimary: DSColor(0xFFB71C1C),
    // Dark red text
    primaryContainer: DSColor(0xFFD32F2F),
    // Deep Christmas red container
    onPrimaryContainer: DSColor(0xFFFFCDD2),
    // Light red text
    primaryFixed: DSColor(0xFFE53935),
    // Fixed vibrant Christmas red
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFD32F2F),
    onPrimaryFixedVariant: DSColor(0xFFB71C1C),

    // Secondary: Glowing Evergreen - warm Christmas tree lights
    secondary: DSColor(0xFF81C784),
    // Light glowing green
    onSecondary: DSColor(0xFF0D4E0F),
    // Dark green text
    secondaryContainer: DSColor(0xFF1B5E20),
    // Deep evergreen container
    onSecondaryContainer: DSColor(0xFFC8E6C9),
    // Light green text
    secondaryFixed: DSColor(0xFF2E7D32),
    // Fixed bright evergreen
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF1B5E20),
    onSecondaryFixedVariant: DSColor(0xFF0D4E0F),

    // Tertiary: Warm Holiday Glow - cozy ornament gold by firelight
    tertiary: DSColor(0xFFFFD54F),
    // Bright warm gold
    onTertiary: DSColor(0xFFFF8F00),
    // Orange text
    tertiaryContainer: DSColor(0xFFFFB300),
    // Holiday gold container
    onTertiaryContainer: DSColor(0xFFFFE082),
    // Light golden text
    tertiaryFixed: DSColor(0xFFFFC107),
    // Fixed pure holiday gold
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFFB300),
    onTertiaryFixedVariant: DSColor(0xFFFF8F00),

    inversePrimary: DSColor(0xFFD32F2F),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing holiday red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Warm gingerbread amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing winter green
    success: DSColor(0xFF81C784),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF2E7D32),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Starlit winter blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1565C0),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF1A1512),
    // Very dark warm background
    grey1: DSColor(0xFF211E1B),
    // Dark surface with warm hint
    grey2: DSColor(0xFF2A2724),
    // Elevated warm surface
    grey3: DSColor(0xFF3A352F),
    // Medium dark warm surface
    grey4: DSColor(0xFF4A433D),
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
    surface: DSColor(0xFF1A1512),
    // Deep warm dark background
    onSurface: DSColor(0xFFE6DDD0),
    // Light warm text
    surfaceVariant: DSColor(0xFF2A1F12),
    // Very dark warm tint
    onSurfaceVariant: DSColor(0xFFEF9A9A),
    // Light red text
    surfaceDim: DSColor(0xFF16120E),
    // Darker warm surface
    surfaceBright: DSColor(0xFF2A2724),
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
    surfaceTint: DSColor(0xFFEF9A9A), // Light red tint for dark
  );
}
