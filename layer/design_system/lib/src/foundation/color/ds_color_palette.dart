import 'package:design_system/src/foundation/color/ds_color_scheme.dart';

/// Material 3 Color Palette
/// Complete color system following Material Design 3 guidelines
/// https://m3.material.io/styles/color/system/overview
/// https://m3.material.io/styles/color/roles
abstract interface class DSColorPalette {
  /// Brand colors for primary, secondary, and tertiary roles
  BrandColorScheme get brand;

  /// Semantic colors for error, warning, success, and info states
  SemanticColorScheme get semantic;

  /// Neutral tonal palette for text, icons, and subtle backgrounds
  NeutralColorScheme get neutral;

  /// Surface colors for backgrounds and containers
  SurfaceColorScheme get surface;

  /// Outline colors for borders and dividers
  OutlineColorScheme get outline;

  /// Utility colors for shadows, scrims, and surface tints
  UtilityColorScheme get utility;
}
