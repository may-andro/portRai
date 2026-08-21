import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Common icons for use cases
extension CommonIcons on BuildContext {
  static const List<IconData> commonIcons = [
    Icons.favorite,
    Icons.share,
    Icons.delete,
    Icons.edit,
    Icons.settings,
    Icons.more_vert,
    Icons.star,
    Icons.home,
    Icons.search,
    Icons.person,
    Icons.notifications,
    Icons.info,
    Icons.check,
    Icons.close,
    Icons.add,
    Icons.remove,
    Icons.menu,
    Icons.arrow_back,
    Icons.arrow_forward,
    Icons.refresh,
  ];
}

/// Typography styles for use cases
extension TypographyStyles on BuildContext {
  List<DSTextStyle> get allTypographyStyles => [
    typography.displayLarge,
    typography.displayMedium,
    typography.displaySmall,
    typography.headlineLarge,
    typography.headlineMedium,
    typography.headlineSmall,
    typography.titleLarge,
    typography.titleMedium,
    typography.titleSmall,
    typography.bodyLarge,
    typography.bodyMedium,
    typography.bodySmall,
    typography.labelLarge,
    typography.labelMedium,
    typography.labelSmall,
  ];

  Map<String, DSTextStyle> get typographyStylesMap => {
    'Display Large': typography.displayLarge,
    'Display Medium': typography.displayMedium,
    'Display Small': typography.displaySmall,
    'Headline Large': typography.headlineLarge,
    'Headline Medium': typography.headlineMedium,
    'Headline Small': typography.headlineSmall,
    'Title Large': typography.titleLarge,
    'Title Medium': typography.titleMedium,
    'Title Small': typography.titleSmall,
    'Body Large': typography.bodyLarge,
    'Body Medium': typography.bodyMedium,
    'Body Small': typography.bodySmall,
    'Label Large': typography.labelLarge,
    'Label Medium': typography.labelMedium,
    'Label Small': typography.labelSmall,
  };
}

/// Common brand colors for use cases
extension BrandColors on BuildContext {
  Map<String, DSColor> get brandColorsMap => {
    'Primary': colorPalette.brand.primary,
    'On Primary': colorPalette.brand.onPrimary,
    'Primary Container': colorPalette.brand.primaryContainer,
    'On Primary Container': colorPalette.brand.onPrimaryContainer,
    'Secondary': colorPalette.brand.secondary,
    'On Secondary': colorPalette.brand.onSecondary,
    'Secondary Container': colorPalette.brand.secondaryContainer,
    'On Secondary Container': colorPalette.brand.onSecondaryContainer,
    'Tertiary': colorPalette.brand.tertiary,
    'On Tertiary': colorPalette.brand.onTertiary,
    'Tertiary Container': colorPalette.brand.tertiaryContainer,
    'On Tertiary Container': colorPalette.brand.onTertiaryContainer,
  };
}

/// Common semantic colors for use cases
extension SemanticColors on BuildContext {
  Map<String, DSColor> get semanticColorsMap => {
    'Error': colorPalette.semantic.error,
    'On Error': colorPalette.semantic.onError,
    'Error Container': colorPalette.semantic.errorContainer,
    'On Error Container': colorPalette.semantic.onErrorContainer,
    'Success': colorPalette.semantic.success,
    'On Success': colorPalette.semantic.onSuccess,
    'Success Container': colorPalette.semantic.successContainer,
    'On Success Container': colorPalette.semantic.onSuccessContainer,
    'Warning': colorPalette.semantic.warning,
    'On Warning': colorPalette.semantic.onWarning,
    'Warning Container': colorPalette.semantic.warningContainer,
    'On Warning Container': colorPalette.semantic.onWarningContainer,
    'Info': colorPalette.semantic.info,
    'On Info': colorPalette.semantic.onInfo,
    'Info Container': colorPalette.semantic.infoContainer,
    'On Info Container': colorPalette.semantic.onInfoContainer,
  };
}

/// Surface colors for use cases
extension SurfaceColors on BuildContext {
  Map<String, DSColor> get surfaceColorsMap => {
    'Surface': colorPalette.surface.surface,
    'On Surface': colorPalette.surface.onSurface,
    'Surface Variant': colorPalette.surface.surfaceVariant,
    'On Surface Variant': colorPalette.surface.onSurfaceVariant,
    'Surface Dim': colorPalette.surface.surfaceDim,
    'Surface Bright': colorPalette.surface.surfaceBright,
    'Surface Container Lowest': colorPalette.surface.surfaceContainerLowest,
    'Surface Container Low': colorPalette.surface.surfaceContainerLow,
    'Surface Container': colorPalette.surface.surfaceContainer,
    'Surface Container High': colorPalette.surface.surfaceContainerHigh,
    'Surface Container Highest': colorPalette.surface.surfaceContainerHighest,
    'Inverse Surface': colorPalette.surface.inverseSurface,
    'On Inverse Surface': colorPalette.surface.onInverseSurface,
  };
}

/// Neutral/grey colors for use cases
extension NeutralColors on BuildContext {
  Map<String, DSColor> get neutralColorsMap => {
    'White': colorPalette.neutral.white,
    'Grey 1': colorPalette.neutral.grey1,
    'Grey 2': colorPalette.neutral.grey2,
    'Grey 3': colorPalette.neutral.grey3,
    'Grey 4': colorPalette.neutral.grey4,
    'Grey 5': colorPalette.neutral.grey5,
    'Grey 6': colorPalette.neutral.grey6,
    'Grey 7': colorPalette.neutral.grey7,
    'Grey 8': colorPalette.neutral.grey8,
    'Grey 9': colorPalette.neutral.grey9,
    'Grey 10': colorPalette.neutral.grey10,
    'Black': colorPalette.neutral.black,
  };
}

/// All colors combined (brand + semantic + surface + neutral + outline)
extension AllColors on BuildContext {
  Map<String, DSColor> get allColorsMap => {
    ...brandColorsMap,
    ...semanticColorsMap,
    ...surfaceColorsMap,
    ...neutralColorsMap,
    'Outline': colorPalette.outline.outline,
    'Outline Variant': colorPalette.outline.outlineVariant,
  };

  /// Container colors (commonly used for card backgrounds)
  Map<String, DSColor?> get containerColorsMap => {
    'Default': null,
    'Primary Container': colorPalette.brand.primaryContainer,
    'Secondary Container': colorPalette.brand.secondaryContainer,
    'Tertiary Container': colorPalette.brand.tertiaryContainer,
    'Error Container': colorPalette.semantic.errorContainer,
    'Success Container': colorPalette.semantic.successContainer,
    'Warning Container': colorPalette.semantic.warningContainer,
    'Info Container': colorPalette.semantic.infoContainer,
    'Surface': colorPalette.surface.surface,
    'Surface Variant': colorPalette.surface.surfaceVariant,
  };

  /// Get contrasting text color for a container background
  DSColor getContainerTextColor(DSColor? backgroundColor) {
    if (backgroundColor == null) return colorPalette.neutral.grey9;
    if (backgroundColor == colorPalette.brand.primaryContainer)
      return colorPalette.brand.onPrimaryContainer;
    if (backgroundColor == colorPalette.brand.secondaryContainer)
      return colorPalette.brand.onSecondaryContainer;
    if (backgroundColor == colorPalette.brand.tertiaryContainer)
      return colorPalette.brand.onTertiaryContainer;
    if (backgroundColor == colorPalette.semantic.errorContainer)
      return colorPalette.semantic.onErrorContainer;
    if (backgroundColor == colorPalette.semantic.successContainer)
      return colorPalette.semantic.onSuccessContainer;
    if (backgroundColor == colorPalette.semantic.warningContainer)
      return colorPalette.semantic.onWarningContainer;
    if (backgroundColor == colorPalette.semantic.infoContainer)
      return colorPalette.semantic.onInfoContainer;
    if (backgroundColor == colorPalette.surface.surface)
      return colorPalette.surface.onSurface;
    if (backgroundColor == colorPalette.surface.surfaceVariant)
      return colorPalette.surface.onSurfaceVariant;
    return colorPalette.neutral.grey9;
  }
}

/// Common dimension helpers for use cases
extension DimenHelpers on BuildContext {
  /// Elevation options with labels
  Map<String, DSElevation> get elevationOptionsMap => {
    'None': dimen.elevationNone,
    'Level 1': dimen.elevationLevel1,
    'Level 2': dimen.elevationLevel2,
    'Level 3': dimen.elevationLevel3,
  };

  /// Radius options with labels
  Map<String, DSRadius> get radiusOptionsMap => {
    'Level 1': dimen.radiusLevel1,
    'Level 2': dimen.radiusLevel2,
    'Level 3': dimen.radiusLevel3,
    'Circular': dimen.radiusCircular,
  };
}
