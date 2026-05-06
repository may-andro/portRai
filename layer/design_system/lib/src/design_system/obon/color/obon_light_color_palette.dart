import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Obon Light Color Palette
/// Inspired by Japanese Buddhist festival during serene summer day
/// Celebrates ancestral honor, spiritual contemplation, and traditional Japanese ceremonies
/// Contemplative purples, lantern golds, and serene blues for light theme
class ObonLightColorPalette implements DSColorPalette {
  const ObonLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Spiritual Purple - deep contemplative purple for ancestral honor
    primary: DSColor(0xFF673AB7),
    // Deep spiritual purple
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFD1C4E9),
    // Light spiritual purple
    onPrimaryContainer: DSColor(0xFF4527A0),
    primaryFixed: DSColor(0xFF7C4DFF),
    // Vibrant spiritual purple
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF673AB7),
    onPrimaryFixedVariant: DSColor(0xFF4527A0),

    // Secondary: Lantern Gold - warm traditional lantern color
    secondary: DSColor(0xFFFF8F00),
    // Traditional lantern gold
    onSecondary: DSColor(0xFF000000),
    secondaryContainer: DSColor(0xFFFFE0B2),
    // Light lantern yellow
    onSecondaryContainer: DSColor(0xFFE65100),
    secondaryFixed: DSColor(0xFFFFA000),
    // Bright lantern gold
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFF8F00),
    onSecondaryFixedVariant: DSColor(0xFFE65100),

    // Tertiary: Moonlit Blue - serene evening sky representing spiritual tranquility
    tertiary: DSColor(0xFF3F51B5),
    // Serene moonlit blue
    onTertiary: DSColor(0xFFFFFFFF),
    tertiaryContainer: DSColor(0xFFC5CAE9),
    // Light moonlit blue
    onTertiaryContainer: DSColor(0xFF283593),
    tertiaryFixed: DSColor(0xFF5C6BC0),
    // Bright moonlit blue
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF3F51B5),
    onTertiaryFixedVariant: DSColor(0xFF283593),

    inversePrimary: DSColor(0xFF9575CD),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Gentle red earth
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Sunset amber
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Peaceful green
    success: DSColor(0xFF388E3C),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Tranquil blue
    info: DSColor(0xFF3F51B5),
    onInfo: DSColor(0xFFFFFFFF),
    infoContainer: DSColor(0xFFC5CAE9),
    onInfoContainer: DSColor(0xFF283593),
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
    surface: DSColor(0xFFFBFBFE),
    // Soft white with purple tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFF3F1F8),
    // Very light purple tint
    onSurfaceVariant: DSColor(0xFF673AB7),
    surfaceDim: DSColor(0xFFF0EEF5),
    // Dimmed purple surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFAF9FC),
    surfaceContainer: DSColor(0xFFF5F3FA),
    surfaceContainerHigh: DSColor(0xFFEFEDF5),
    surfaceContainerHighest: DSColor(0xFFE9E7F0),
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
    surfaceTint: DSColor(0xFF673AB7), // Primary purple tint
  );
}
