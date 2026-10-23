import 'package:design_system/src/theme/ds_theme.dart';
import 'package:flutter/material.dart';

extension DSThemeExtension on DSTheme {
  ThemeData get theme {
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
    );
  }

  ColorScheme get colorScheme {
    return ColorScheme.fromSeed(
      seedColor: colorPalette.brand.primary.color,
      brightness: brightness,
    ).copyWith(
      // Primary brand colors
      primary: colorPalette.brand.primary.color,
      onPrimary: colorPalette.brand.onPrimary.color,
      primaryContainer: colorPalette.brand.primaryContainer.color,
      onPrimaryContainer: colorPalette.brand.onPrimaryContainer.color,
      primaryFixed: colorPalette.brand.primaryFixed.color,
      onPrimaryFixed: colorPalette.brand.onPrimaryFixed.color,
      primaryFixedDim: colorPalette.brand.primaryFixedDim.color,
      onPrimaryFixedVariant: colorPalette.brand.onPrimaryFixedVariant.color,
      inversePrimary: colorPalette.brand.inversePrimary.color,

      // Secondary brand colors
      secondary: colorPalette.brand.secondary.color,
      onSecondary: colorPalette.brand.onSecondary.color,
      secondaryContainer: colorPalette.brand.secondaryContainer.color,
      onSecondaryContainer: colorPalette.brand.onSecondaryContainer.color,
      secondaryFixed: colorPalette.brand.secondaryFixed.color,
      onSecondaryFixed: colorPalette.brand.onSecondaryFixed.color,
      secondaryFixedDim: colorPalette.brand.secondaryFixedDim.color,
      onSecondaryFixedVariant: colorPalette.brand.onSecondaryFixedVariant.color,

      // Tertiary brand colors
      tertiary: colorPalette.brand.tertiary.color,
      onTertiary: colorPalette.brand.onTertiary.color,
      tertiaryContainer: colorPalette.brand.tertiaryContainer.color,
      onTertiaryContainer: colorPalette.brand.onTertiaryContainer.color,
      tertiaryFixed: colorPalette.brand.tertiaryFixed.color,
      onTertiaryFixed: colorPalette.brand.onTertiaryFixed.color,
      tertiaryFixedDim: colorPalette.brand.tertiaryFixedDim.color,
      onTertiaryFixedVariant: colorPalette.brand.onTertiaryFixedVariant.color,

      // Surface colors
      surface: colorPalette.surface.surface.color,
      onSurface: colorPalette.surface.onSurface.color,
      onSurfaceVariant: colorPalette.surface.onSurfaceVariant.color,
      surfaceDim: colorPalette.surface.surfaceDim.color,
      surfaceBright: colorPalette.surface.surfaceBright.color,
      surfaceContainerLowest: colorPalette.surface.surfaceContainerLowest.color,
      surfaceContainerLow: colorPalette.surface.surfaceContainerLow.color,
      surfaceContainer: colorPalette.surface.surfaceContainer.color,
      surfaceContainerHigh: colorPalette.surface.surfaceContainerHigh.color,
      surfaceContainerHighest:
          colorPalette.surface.surfaceContainerHighest.color,
      inverseSurface: colorPalette.surface.inverseSurface.color,
      onInverseSurface: colorPalette.surface.onInverseSurface.color,

      // Semantic error colors
      error: colorPalette.semantic.error.color,
      onError: colorPalette.semantic.onError.color,
      errorContainer: colorPalette.semantic.errorContainer.color,
      onErrorContainer: colorPalette.semantic.onErrorContainer.color,

      // Outline colors
      outline: colorPalette.outline.outline.color,
      outlineVariant: colorPalette.outline.outlineVariant.color,

      // Utility colors
      shadow: colorPalette.utility.shadow.color,
      scrim: colorPalette.utility.scrim.color,
      surfaceTint: colorPalette.utility.surfaceTint.color,

      brightness: brightness,
    );
  }
}
