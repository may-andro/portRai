import 'package:design_system/src/foundation/color/ds_color.dart';
import 'package:design_system/src/foundation/color/ds_color_palette.dart';

/// Material 3 Color Roles Helper
/// Provides semantic access to colors based on their intended use cases
/// Based on Material Design 3 color roles and guidelines
extension DsColorRolesExtension on DSColorPalette {
  // MARK: - Primary Action Colors
  /// Primary action color for key components like FABs, primary buttons
  DSColor get primaryAction => brand.primary;

  /// Text/icons on primary action components
  DSColor get onPrimaryAction => brand.onPrimary;

  /// Containers for primary actions (chips, cards with primary content)
  DSColor get primaryActionContainer => brand.primaryContainer;

  /// Text/icons on primary action containers
  DSColor get onPrimaryActionContainer => brand.onPrimaryContainer;

  // MARK: - Secondary Action Colors
  /// Secondary action color for supporting components
  DSColor get secondaryAction => brand.secondary;

  /// Text/icons on secondary action components
  DSColor get onSecondaryAction => brand.onSecondary;

  /// Containers for secondary actions
  DSColor get secondaryActionContainer => brand.secondaryContainer;

  /// Text/icons on secondary action containers
  DSColor get onSecondaryActionContainer => brand.onSecondaryContainer;

  // MARK: - Accent Colors
  /// Accent color for highlighting and emphasis
  DSColor get accent => brand.tertiary;

  /// Text/icons on accent color
  DSColor get onAccent => brand.onTertiary;

  /// Accent containers for emphasized content
  DSColor get accentContainer => brand.tertiaryContainer;

  /// Text/icons on accent containers
  DSColor get onAccentContainer => brand.onTertiaryContainer;

  // MARK: - Surface Colors
  /// Main surface color for app backgrounds
  DSColor get background => surface.surface;

  /// Primary text and icons on surfaces
  DSColor get onBackground => surface.onSurface;

  /// Variant surface for subtle differentiation
  DSColor get surfaceVariant => surface.surfaceVariant;

  /// Text and icons on surface variants
  DSColor get onSurfaceVariant => surface.onSurfaceVariant;

  // MARK: - Container Colors (By Elevation)
  /// Lowest elevation containers (cards at rest)
  DSColor get containerLowest => surface.surfaceContainerLowest;

  /// Low elevation containers (elevated cards)
  DSColor get containerLow => surface.surfaceContainerLow;

  /// Standard elevation containers (most cards)
  DSColor get container => surface.surfaceContainer;

  /// High elevation containers (modals, dialogs)
  DSColor get containerHigh => surface.surfaceContainerHigh;

  /// Highest elevation containers (tooltips, menus)
  DSColor get containerHighest => surface.surfaceContainerHighest;

  // MARK: - Text Colors
  /// Primary text color (headlines, body text)
  DSColor get textPrimary => surface.onSurface;

  /// Secondary text color (captions, supporting text)
  DSColor get textSecondary => surface.onSurfaceVariant;

  /// Disabled text color
  DSColor get textDisabled => neutral.grey4;

  /// Text on colored backgrounds
  DSColor get textOnColor => neutral.grey10;

  // MARK: - Border and Outline Colors
  /// Primary borders and dividers
  DSColor get border => outline.outline;

  /// Subtle borders and decorative outlines
  DSColor get borderSubtle => outline.outlineVariant;

  // MARK: - Semantic State Colors
  /// Error state color
  DSColor get error => semantic.error;

  /// Text/icons on error color
  DSColor get onError => semantic.onError;

  /// Error containers (error messages, alerts)
  DSColor get errorContainer => semantic.errorContainer;

  /// Text/icons on error containers
  DSColor get onErrorContainer => semantic.onErrorContainer;

  /// Warning state color
  DSColor get warning => semantic.warning;

  /// Text/icons on warning color
  DSColor get onWarning => semantic.onWarning;

  /// Warning containers
  DSColor get warningContainer => semantic.warningContainer;

  /// Text/icons on warning containers
  DSColor get onWarningContainer => semantic.onWarningContainer;

  /// Success state color
  DSColor get success => semantic.success;

  /// Text/icons on success color
  DSColor get onSuccess => semantic.onSuccess;

  /// Success containers
  DSColor get successContainer => semantic.successContainer;

  /// Text/icons on success containers
  DSColor get onSuccessContainer => semantic.onSuccessContainer;

  /// Info state color
  DSColor get info => semantic.info;

  /// Text/icons on info color
  DSColor get onInfo => semantic.onInfo;

  /// Info containers
  DSColor get infoContainer => semantic.infoContainer;

  /// Text/icons on info containers
  DSColor get onInfoContainer => semantic.onInfoContainer;

  // MARK: - Utility Colors
  /// Shadow color for elevation
  DSColor get shadow => utility.shadow;

  /// Scrim color for overlays
  DSColor get scrim => utility.scrim;

  /// Surface tint for material surfaces
  DSColor get surfaceTint => utility.surfaceTint;

  // MARK: - Disabled Colors
  /// General disabled color for backgrounds, icons, etc.
  DSColor get disabled => neutral.grey4;

  /// Text/icons on disabled backgrounds (if available in palette)
  DSColor get onDisabled => neutral.grey10;

  // MARK: - Special Purpose Colors
  /// Inverse surface for contrast
  DSColor get inverseSurface => surface.inverseSurface;

  /// Text/icons on inverse surface
  DSColor get onInverseSurface => surface.onInverseSurface;

  /// Inverse primary for themes
  DSColor get inversePrimary => brand.inversePrimary;

  /// Transparent color
  DSColor get transparent => neutral.transparent;
}
