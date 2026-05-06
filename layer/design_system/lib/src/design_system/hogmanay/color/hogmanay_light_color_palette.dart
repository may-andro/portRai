import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Hogmanay Light Color Palette
/// Inspired by Scottish New Year celebration during bright winter day
/// Celebrates Highland traditions, tartan heritage, and festive Scottish spirit
/// Deep blues, Highland greens, and silver whites for light theme
class HogmanayLightColorPalette implements DSColorPalette {
  const HogmanayLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Scottish Highland Blue - deep royal blue of Scottish flag
    primary: DSColor(0xFF0D47A1),
    // Deep Scottish blue
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFBBDEFB),
    // Light Highland blue
    onPrimaryContainer: DSColor(0xFF01579B),
    primaryFixed: DSColor(0xFF1976D2),
    // Bright Scottish blue
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF1565C0),
    onPrimaryFixedVariant: DSColor(0xFF01579B),

    // Secondary: Highland Green - Scottish forest and tartan green
    secondary: DSColor(0xFF1B5E20),
    // Deep Highland green
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFC8E6C9),
    // Light Highland green
    onSecondaryContainer: DSColor(0xFF0D4E0F),
    secondaryFixed: DSColor(0xFF2E7D32),
    // Bright Highland green
    onSecondaryFixed: DSColor(0xFFFFFFFF),
    secondaryFixedDim: DSColor(0xFF1B5E20),
    onSecondaryFixedVariant: DSColor(0xFF0D4E0F),

    // Tertiary: Silver White - winter snow and Celtic silver
    tertiary: DSColor(0xFF455A64),
    // Cool silver grey
    onTertiary: DSColor(0xFFFFFFFF),
    tertiaryContainer: DSColor(0xFFECEFF1),
    // Light silver white
    onTertiaryContainer: DSColor(0xFF263238),
    tertiaryFixed: DSColor(0xFF607D8B),
    // Bright silver
    onTertiaryFixed: DSColor(0xFFFFFFFF),
    tertiaryFixedDim: DSColor(0xFF546E7A),
    onTertiaryFixedVariant: DSColor(0xFF263238),

    inversePrimary: DSColor(0xFF64B5F6),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Highland red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Highland amber
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Celtic green
    success: DSColor(0xFF2E7D32),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Scottish blue
    info: DSColor(0xFF1976D2),
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
    surface: DSColor(0xFFFAFBFC),
    // Cool white with blue tint
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFF3F5F7),
    // Very light blue tint
    onSurfaceVariant: DSColor(0xFF0D47A1),
    surfaceDim: DSColor(0xFFEFF2F5),
    // Dimmed blue surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFF9FAFB),
    surfaceContainer: DSColor(0xFFF3F5F7),
    surfaceContainerHigh: DSColor(0xFFEDF0F3),
    surfaceContainerHighest: DSColor(0xFFE7EAEE),
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
    surfaceTint: DSColor(0xFF0D47A1), // Primary blue tint
  );
}
