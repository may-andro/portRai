import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Hogmanay Dark Color Palette
/// Inspired by Scottish New Year celebration during magical Highland night
/// Celebrates the mystical atmosphere of midnight Highland festivities under starlit skies
/// Luminous blues, moonlit greens, and glowing silvers for dark theme
class HogmanayDarkColorPalette implements DSColorPalette {
  const HogmanayDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Moonlit Highland Blue - luminous Scottish blue in darkness
    primary: DSColor(0xFF64B5F6),
    // Light luminous blue
    onPrimary: DSColor(0xFF01579B),
    // Dark blue text
    primaryContainer: DSColor(0xFF0D47A1),
    // Deep Scottish blue container
    onPrimaryContainer: DSColor(0xFFBBDEFB),
    // Light blue text
    primaryFixed: DSColor(0xFF1976D2),
    // Fixed bright Scottish blue
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF1565C0),
    onPrimaryFixedVariant: DSColor(0xFF01579B),

    // Secondary: Moonlit Highland Green - mystical Scottish forest glow
    secondary: DSColor(0xFF66BB6A),
    // Light Highland green
    onSecondary: DSColor(0xFF0D4E0F),
    // Dark green text
    secondaryContainer: DSColor(0xFF1B5E20),
    // Deep Highland green container
    onSecondaryContainer: DSColor(0xFFC8E6C9),
    // Light green text
    secondaryFixed: DSColor(0xFF2E7D32),
    // Fixed bright Highland green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF1B5E20),
    onSecondaryFixedVariant: DSColor(0xFF0D4E0F),

    // Tertiary: Glowing Silver - ethereal moonlight and Celtic magic
    tertiary: DSColor(0xFF90A4AE),
    // Bright glowing silver
    onTertiary: DSColor(0xFF263238),
    // Dark grey text
    tertiaryContainer: DSColor(0xFF455A64),
    // Cool silver grey container
    onTertiaryContainer: DSColor(0xFFECEFF1),
    // Light silver text
    tertiaryFixed: DSColor(0xFF607D8B),
    // Fixed bright silver
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF546E7A),
    onTertiaryFixedVariant: DSColor(0xFF263238),

    inversePrimary: DSColor(0xFF0D47A1),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Glowing Highland red
    error: DSColor(0xFFEF5350),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFD32F2F),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Moonlit Highland amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFF8F00),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing Celtic green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF2E7D32),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Starlit Scottish blue
    info: DSColor(0xFF42A5F5),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF1976D2),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF0F1419),
    // Very dark cool background with blue hint
    grey1: DSColor(0xFF1A1F24),
    // Dark surface with cool hint
    grey2: DSColor(0xFF242A30),
    // Elevated cool surface
    grey3: DSColor(0xFF2F363D),
    // Medium dark cool surface
    grey4: DSColor(0xFF3A424A),
    // Lighter dark cool surface
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
    surface: DSColor(0xFF0F1419),
    // Deep cool dark background
    onSurface: DSColor(0xFFE7EAEE),
    // Light cool text
    surfaceVariant: DSColor(0xFF1A2227),
    // Very dark cool tint
    onSurfaceVariant: DSColor(0xFF64B5F6),
    // Light blue text
    surfaceDim: DSColor(0xFF0D1116),
    // Darker cool surface
    surfaceBright: DSColor(0xFF242A30),
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
    inverseSurface: DSColor(0xFFE7EAEE),
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
    surfaceTint: DSColor(0xFF64B5F6), // Light blue tint for dark
  );
}
