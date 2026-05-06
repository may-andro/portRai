import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Obon Dark Color Palette
/// Inspired by Japanese Buddhist festival during peaceful evening lantern ceremonies
/// Celebrates the serene atmosphere of ancestral honor under moonlit summer nights
/// Glowing purples, luminous golds, and tranquil blues for dark theme
class ObonDarkColorPalette implements DSColorPalette {
  const ObonDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Glowing Spiritual Light - luminous purple in peaceful darkness
    primary: DSColor(0xFF9575CD),
    // Light spiritual purple
    onPrimary: DSColor(0xFF4527A0),
    // Dark purple text
    primaryContainer: DSColor(0xFF673AB7),
    // Deep spiritual purple container
    onPrimaryContainer: DSColor(0xFFD1C4E9),
    // Light purple text
    primaryFixed: DSColor(0xFF7C4DFF),
    // Fixed vibrant spiritual purple
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF673AB7),
    onPrimaryFixedVariant: DSColor(0xFF4527A0),

    // Secondary: Glowing Lantern - warm traditional lantern glow in darkness
    secondary: DSColor(0xFFFFCC02),
    // Bright glowing lantern gold
    onSecondary: DSColor(0xFFE65100),
    // Dark orange text
    secondaryContainer: DSColor(0xFFFF8F00),
    // Traditional lantern gold container
    onSecondaryContainer: DSColor(0xFFFFE0B2),
    // Light golden text
    secondaryFixed: DSColor(0xFFFFA000),
    // Fixed bright lantern gold
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFF8F00),
    onSecondaryFixedVariant: DSColor(0xFFE65100),

    // Tertiary: Serene Moonlight - tranquil evening sky glow
    tertiary: DSColor(0xFF7986CB),
    // Light moonlit blue
    onTertiary: DSColor(0xFF283593),
    // Dark blue text
    tertiaryContainer: DSColor(0xFF3F51B5),
    // Serene moonlit blue container
    onTertiaryContainer: DSColor(0xFFC5CAE9),
    // Light blue text
    tertiaryFixed: DSColor(0xFF5C6BC0),
    // Fixed bright moonlit blue
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF3F51B5),
    onTertiaryFixedVariant: DSColor(0xFF283593),

    inversePrimary: DSColor(0xFF673AB7),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Gentle glowing red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Luminous sunset amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Peaceful moonlit green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF388E3C),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Serene tranquil blue
    info: DSColor(0xFF5C6BC0),
    onInfo: DSColor(0xFF283593),
    infoContainer: DSColor(0xFF3F51B5),
    onInfoContainer: DSColor(0xFFC5CAE9),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF161218),
    // Very dark background with purple hint
    grey1: DSColor(0xFF1E1A20),
    // Dark surface with spiritual hint
    grey2: DSColor(0xFF282329),
    // Elevated spiritual surface
    grey3: DSColor(0xFF353035),
    // Medium dark spiritual surface
    grey4: DSColor(0xFF453F45),
    // Lighter dark spiritual surface
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
    surface: DSColor(0xFF161218),
    // Deep spiritual dark background
    onSurface: DSColor(0xFFE9E7F0),
    // Light spiritual text
    surfaceVariant: DSColor(0xFF221C28),
    // Very dark purple tint
    onSurfaceVariant: DSColor(0xFF9575CD),
    // Light purple text
    surfaceDim: DSColor(0xFF130F15),
    // Darker spiritual surface
    surfaceBright: DSColor(0xFF282329),
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
    inverseSurface: DSColor(0xFFE9E7F0),
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
    surfaceTint: DSColor(0xFF9575CD), // Light purple tint for dark
  );
}
