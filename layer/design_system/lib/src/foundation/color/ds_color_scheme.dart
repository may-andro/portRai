import 'package:design_system/src/foundation/color/ds_color.dart';

/// Material 3 Surface Color Scheme
/// Provides surfaces for components and content areas
class SurfaceColorScheme {
  const SurfaceColorScheme({
    required this.surface,
    required this.onSurface,
    required this.surfaceVariant,
    required this.onSurfaceVariant,
    required this.surfaceDim,
    required this.surfaceBright,
    required this.surfaceContainerLowest,
    required this.surfaceContainerLow,
    required this.surfaceContainer,
    required this.surfaceContainerHigh,
    required this.surfaceContainerHighest,
    required this.inverseSurface,
    required this.onInverseSurface,
    required this.inverseOnSurface,
  });

  /// Primary surface color for main content areas
  final DSColor surface;

  /// Text and icons on surface
  final DSColor onSurface;

  /// Variant surface for subtle differentiation
  final DSColor surfaceVariant;

  /// Text and icons on surface variant
  final DSColor onSurfaceVariant;

  /// Dimmed surface for less emphasis
  final DSColor surfaceDim;

  /// Bright surface for emphasis
  final DSColor surfaceBright;

  /// Lowest elevation surface container
  final DSColor surfaceContainerLowest;

  /// Low elevation surface container
  final DSColor surfaceContainerLow;

  /// Standard surface container
  final DSColor surfaceContainer;

  /// High elevation surface container
  final DSColor surfaceContainerHigh;

  /// Highest elevation surface container
  final DSColor surfaceContainerHighest;

  /// Inverse surface for dark mode support
  final DSColor inverseSurface;

  /// Text and icons on inverse surface
  final DSColor onInverseSurface;

  /// Inverse color for text on surface
  final DSColor inverseOnSurface;
}

/// Material 3 Outline Color Scheme
/// Provides borders and dividers
class OutlineColorScheme {
  const OutlineColorScheme({
    required this.outline,
    required this.outlineVariant,
  });

  /// Primary outline for borders and dividers
  final DSColor outline;

  /// Variant outline for decorative elements
  final DSColor outlineVariant;
}

/// Material 3 Utility Color Scheme
/// Provides special purpose colors
class UtilityColorScheme {
  const UtilityColorScheme({
    required this.shadow,
    required this.scrim,
    required this.surfaceTint,
  });

  /// Shadow color for elevation
  final DSColor shadow;

  /// Scrim color for overlays
  final DSColor scrim;

  /// Surface tint for material surfaces
  final DSColor surfaceTint;
}

/// Material 3 Neutral Color Scheme (Tonal Palette)
/// Provides neutral colors from white to black
class NeutralColorScheme {
  const NeutralColorScheme({
    required this.white,
    required this.grey1,
    required this.grey2,
    required this.grey3,
    required this.grey4,
    required this.grey5,
    required this.grey6,
    required this.grey7,
    required this.grey8,
    required this.grey9,
    required this.grey10,
    required this.black,
  });

  final DSColor white;

  final DSColor grey1;

  final DSColor grey2;

  final DSColor grey3;

  final DSColor grey4;

  final DSColor grey5;

  final DSColor grey6;

  final DSColor grey7;

  final DSColor grey8;

  final DSColor grey9;

  final DSColor grey10;

  final DSColor black;

  DSColor get transparent => const DSColor(0x00000000);
}

/// Material 3 Semantic Color Scheme
/// Provides semantic meaning colors (success, warning, error, info)
class SemanticColorScheme {
  const SemanticColorScheme({
    required this.error,
    required this.onError,
    required this.errorContainer,
    required this.onErrorContainer,
    required this.warning,
    required this.onWarning,
    required this.warningContainer,
    required this.onWarningContainer,
    required this.success,
    required this.onSuccess,
    required this.successContainer,
    required this.onSuccessContainer,
    required this.info,
    required this.onInfo,
    required this.infoContainer,
    required this.onInfoContainer,
  });

  /// Error color for destructive actions
  final DSColor error;

  /// Text and icons on error color
  final DSColor onError;

  /// Container for error content
  final DSColor errorContainer;

  /// Text and icons on error container
  final DSColor onErrorContainer;

  /// Warning color for caution
  final DSColor warning;

  /// Text and icons on warning color
  final DSColor onWarning;

  /// Container for warning content
  final DSColor warningContainer;

  /// Text and icons on warning container
  final DSColor onWarningContainer;

  /// Success color for positive actions
  final DSColor success;

  /// Text and icons on success color
  final DSColor onSuccess;

  /// Container for success content
  final DSColor successContainer;

  /// Text and icons on success container
  final DSColor onSuccessContainer;

  /// Info color for informational content
  final DSColor info;

  /// Text and icons on info color
  final DSColor onInfo;

  /// Container for info content
  final DSColor infoContainer;

  /// Text and icons on info container
  final DSColor onInfoContainer;
}

/// Material 3 Brand Color Scheme
/// Provides primary brand colors and key colors
class BrandColorScheme {
  const BrandColorScheme({
    required this.primary,
    required this.onPrimary,
    required this.primaryContainer,
    required this.onPrimaryContainer,
    required this.primaryFixed,
    required this.onPrimaryFixed,
    required this.primaryFixedDim,
    required this.onPrimaryFixedVariant,
    required this.secondary,
    required this.onSecondary,
    required this.secondaryContainer,
    required this.onSecondaryContainer,
    required this.secondaryFixed,
    required this.onSecondaryFixed,
    required this.secondaryFixedDim,
    required this.onSecondaryFixedVariant,
    required this.tertiary,
    required this.onTertiary,
    required this.tertiaryContainer,
    required this.onTertiaryContainer,
    required this.tertiaryFixed,
    required this.onTertiaryFixed,
    required this.tertiaryFixedDim,
    required this.onTertiaryFixedVariant,
    required this.inversePrimary,
  });

  /// Primary brand color for key components
  final DSColor primary;

  /// Text and icons on primary color
  final DSColor onPrimary;

  /// Container for primary content
  final DSColor primaryContainer;

  /// Text and icons on primary container
  final DSColor onPrimaryContainer;

  /// Fixed primary color (consistent across themes)
  final DSColor primaryFixed;

  /// Text and icons on primary fixed
  final DSColor onPrimaryFixed;

  /// Dimmed fixed primary color
  final DSColor primaryFixedDim;

  /// Variant text on primary fixed
  final DSColor onPrimaryFixedVariant;

  /// Secondary brand color
  final DSColor secondary;

  /// Text and icons on secondary color
  final DSColor onSecondary;

  /// Container for secondary content
  final DSColor secondaryContainer;

  /// Text and icons on secondary container
  final DSColor onSecondaryContainer;

  /// Fixed secondary color (consistent across themes)
  final DSColor secondaryFixed;

  /// Text and icons on secondary fixed
  final DSColor onSecondaryFixed;

  /// Dimmed fixed secondary color
  final DSColor secondaryFixedDim;

  /// Variant text on secondary fixed
  final DSColor onSecondaryFixedVariant;

  /// Tertiary brand color for accents
  final DSColor tertiary;

  /// Text and icons on tertiary color
  final DSColor onTertiary;

  /// Container for tertiary content
  final DSColor tertiaryContainer;

  /// Text and icons on tertiary container
  final DSColor onTertiaryContainer;

  /// Fixed tertiary color (consistent across themes)
  final DSColor tertiaryFixed;

  /// Text and icons on tertiary fixed
  final DSColor onTertiaryFixed;

  /// Dimmed fixed tertiary color
  final DSColor tertiaryFixedDim;

  /// Variant text on tertiary fixed
  final DSColor onTertiaryFixedVariant;

  /// Inverse primary for dark mode support
  final DSColor inversePrimary;
}
