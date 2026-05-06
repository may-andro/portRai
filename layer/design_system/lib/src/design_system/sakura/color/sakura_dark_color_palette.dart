import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Sakura Dark Color Palette
/// Inspired by Japanese Cherry Blossom festival during magical evening hanami
/// Celebrates the ethereal beauty of moonlit cherry blossoms and peaceful contemplation
/// Glowing pinks, luminous greens, and serene moonlight for dark theme
class SakuraDarkColorPalette implements DSColorPalette {
  const SakuraDarkColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Moonlit Cherry Blossoms - ethereal pink glow in darkness
    primary: DSColor(0xFFF48FB1),
    // Light ethereal pink
    onPrimary: DSColor(0xFF880E4F),
    // Dark pink text
    primaryContainer: DSColor(0xFFE91E63),
    // Cherry blossom pink container
    onPrimaryContainer: DSColor(0xFFF8BBD9),
    // Light pink text
    primaryFixed: DSColor(0xFFEC407A),
    // Fixed vibrant cherry pink
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE91E63),
    onPrimaryFixedVariant: DSColor(0xFF880E4F),

    // Secondary: Moonlit Spring Leaves - gentle green glow
    secondary: DSColor(0xFF81C784),
    // Light spring green
    onSecondary: DSColor(0xFF1B5E20),
    // Dark green text
    secondaryContainer: DSColor(0xFF4CAF50),
    // Fresh spring green container
    onSecondaryContainer: DSColor(0xFFC8E6C9),
    // Light green text
    secondaryFixed: DSColor(0xFF66BB6A),
    // Fixed bright spring green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF4CAF50),
    onSecondaryFixedVariant: DSColor(0xFF1B5E20),

    // Tertiary: Serene Moonlight - tranquil evening sky
    tertiary: DSColor(0xFF90A4AE),
    // Light serene blue-grey
    onTertiary: DSColor(0xFF263238),
    // Dark grey text
    tertiaryContainer: DSColor(0xFF607D8B),
    // Soft blue-grey container
    onTertiaryContainer: DSColor(0xFFECEFF1),
    // Light grey text
    tertiaryFixed: DSColor(0xFF78909C),
    // Fixed light blue-grey
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF607D8B),
    onTertiaryFixedVariant: DSColor(0xFF263238),

    inversePrimary: DSColor(0xFFE91E63),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Gentle glowing rose
    error: DSColor(0xFFEF9A9A),
    onError: DSColor(0xFFB71C1C),
    errorContainer: DSColor(0xFFE57373),
    onErrorContainer: DSColor(0xFFFFCDD2),

    // Warning: Soft moonlit amber
    warning: DSColor(0xFFFFCC02),
    onWarning: DSColor(0xFFE65100),
    warningContainer: DSColor(0xFFFFB74D),
    onWarningContainer: DSColor(0xFFFFE0B2),

    // Success: Glowing new leaves
    success: DSColor(0xFF81C784),
    onSuccess: DSColor(0xFF1B5E20),
    successContainer: DSColor(0xFF66BB6A),
    onSuccessContainer: DSColor(0xFFC8E6C9),

    // Info: Starlit spring sky
    info: DSColor(0xFF64B5F6),
    onInfo: DSColor(0xFF0D47A1),
    infoContainer: DSColor(0xFF42A5F5),
    onInfoContainer: DSColor(0xFFBBDEFB),
  );

  @override
  NeutralColorScheme get neutral => const NeutralColorScheme(
    white: DSColor(0xFF1A161A),
    // Very dark background with pink hint
    grey1: DSColor(0xFF211D21),
    // Dark surface with soft hint
    grey2: DSColor(0xFF2A262A),
    // Elevated soft surface
    grey3: DSColor(0xFF3A333A),
    // Medium dark soft surface
    grey4: DSColor(0xFF4A414A),
    // Lighter dark soft surface
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
    surface: DSColor(0xFF1A161A),
    // Deep soft dark background
    onSurface: DSColor(0xFFE6DDE6),
    // Light soft text
    surfaceVariant: DSColor(0xFF2A1F2A),
    // Very dark soft tint
    onSurfaceVariant: DSColor(0xFFF48FB1),
    // Light pink text
    surfaceDim: DSColor(0xFF161316),
    // Darker soft surface
    surfaceBright: DSColor(0xFF2A262A),
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
