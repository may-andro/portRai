import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';
import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Carnival Light Color Palette
/// Inspired by vibrant Carnival celebrations during bright festive day
/// Celebrates joy, energy, and the exuberant spirit of pre-Lenten festivities
/// Bold purples, festive oranges, and golden celebration colors for light theme
class CarnivalLightColorPalette implements DSColorPalette {
  const CarnivalLightColorPalette();

  @override
  BrandColorScheme get brand => const BrandColorScheme(
    // Primary: Royal Carnival Purple
    primary: DSColor(0xFF6A1B9A),
    // Deep vibrant purple
    onPrimary: DSColor(0xFFFFFFFF),
    primaryContainer: DSColor(0xFFE1BEE7),
    // Light lavender
    onPrimaryContainer: DSColor(0xFF4A148C),
    primaryFixed: DSColor(0xFF9C27B0),
    // Bright purple
    onPrimaryFixed: DSColor(0xFFFFFFFF),
    primaryFixedDim: DSColor(0xFF7B1FA2),
    onPrimaryFixedVariant: DSColor(0xFF4A148C),

    // Secondary: Festive Orange
    secondary: DSColor(0xFFE65100),
    // Vibrant carnival orange
    onSecondary: DSColor(0xFFFFFFFF),
    secondaryContainer: DSColor(0xFFFFE0B2),
    // Light peach
    onSecondaryContainer: DSColor(0xFFBF360C),
    secondaryFixed: DSColor(0xFFFF9800),
    // Bright orange
    onSecondaryFixed: DSColor(0xFF000000),
    secondaryFixedDim: DSColor(0xFFFF6F00),
    onSecondaryFixedVariant: DSColor(0xFFBF360C),

    // Tertiary: Golden Celebration
    tertiary: DSColor(0xFFFFD600),
    // Bright carnival gold
    onTertiary: DSColor(0xFF000000),
    tertiaryContainer: DSColor(0xFFFFF9C4),
    // Light yellow
    onTertiaryContainer: DSColor(0xFFFF8F00),
    tertiaryFixed: DSColor(0xFFFFEB3B),
    // Pure festival yellow
    onTertiaryFixed: DSColor(0xFF000000),
    tertiaryFixedDim: DSColor(0xFFFDD835),
    onTertiaryFixedVariant: DSColor(0xFFFF8F00),

    inversePrimary: DSColor(0xFFBA68C8),
  );

  @override
  SemanticColorScheme get semantic => const SemanticColorScheme(
    // Error: Deep carnival red
    error: DSColor(0xFFD32F2F),
    onError: DSColor(0xFFFFFFFF),
    errorContainer: DSColor(0xFFFFCDD2),
    onErrorContainer: DSColor(0xFFB71C1C),

    // Warning: Festival amber
    warning: DSColor(0xFFFF8F00),
    onWarning: DSColor(0xFF000000),
    warningContainer: DSColor(0xFFFFE0B2),
    onWarningContainer: DSColor(0xFFE65100),

    // Success: Celebration green
    success: DSColor(0xFF388E3C),
    onSuccess: DSColor(0xFFFFFFFF),
    successContainer: DSColor(0xFFC8E6C9),
    onSuccessContainer: DSColor(0xFF1B5E20),

    // Info: Party blue
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
    surface: DSColor(0xFFFFFBFE),
    // Warm white
    onSurface: DSColor(0xFF1C1B1F),
    surfaceVariant: DSColor(0xFFF3E5F5),
    // Very light purple tint
    onSurfaceVariant: DSColor(0xFF6A1B9A),
    surfaceDim: DSColor(0xFFF5E6FF),
    // Dimmed purple surface
    surfaceBright: DSColor(0xFFFFFFFF),
    surfaceContainerLowest: DSColor(0xFFFFFFFF),
    surfaceContainerLow: DSColor(0xFFFEF7FF),
    surfaceContainer: DSColor(0xFFF3E5F5),
    surfaceContainerHigh: DSColor(0xFFECDDEF),
    surfaceContainerHighest: DSColor(0xFFE6D7EA),
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
    surfaceTint: DSColor(0xFF6A1B9A), // Primary purple tint
  );
}
