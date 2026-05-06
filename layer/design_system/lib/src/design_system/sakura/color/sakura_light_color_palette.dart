import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Sakura Light Color Palette
/// Inspired by Japanese Cherry Blossom festival during bright spring day
/// Celebrates spring beauty, renewal, and the ephemeral nature of life
/// Soft pinks, delicate whites, and serene greens for light theme
class SakuraLightColorPalette implements DSColorPalette {
  const SakuraLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Cherry Blossom Pink - soft, delicate pink representing sakura petals
    primary: DSColor(0xFFE91E63),
    // Gentle cherry blossom pink
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFF8BBD9),
    // Very light sakura pink
    onPrimaryContainer: DSColor(0xFF880E4F),
    primaryFixed: DSColor(0xFFEC407A),
    // Vibrant cherry pink
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFFE91E63),
    onPrimaryFixedVariant: DSColor(0xFF880E4F),

    // Secondary: Spring Green - fresh new leaves and bamboo
    secondary: DSColor(0xFF4CAF50),
    // Fresh spring green
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFC8E6C9),
    // Light spring green
    onSecondaryContainer: DSColor(0xFF1B5E20),
    secondaryFixed: DSColor(0xFF66BB6A),
    // Bright spring green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF4CAF50),
    onSecondaryFixedVariant: DSColor(0xFF1B5E20),

    // Tertiary: Peaceful White - pure snow white representing purity and peace
    tertiary: DSColor(0xFF607D8B),
    // Soft blue-grey
    onTertiary: DSColor(0xFFFFFFFF),
    tertiaryContainer: DSColor(0xFFECEFF1),
    // Very light blue-grey
    onTertiaryContainer: DSColor(0xFF263238),
    tertiaryFixed: DSColor(0xFF78909C),
    // Light blue-grey
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF607D8B),
    onTertiaryFixedVariant: DSColor(0xFF263238),

    inversePrimary: DSColor(0xFFE1BEE7),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Gentle rose red
    error: DSColor(0xFFE57373),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Soft amber
    warning: DSColor(0xFFFFB74D),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: New leaf green
    success: DSColor(0xFF66BB6A),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Spring sky blue
    info: DSColor(0xFF42A5F5),
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
    // Soft white with pink tint
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
    surfaceTint: DSColor(0xFFE91E63), // Primary pink tint
  );
}
