import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color first, Color second) {
  final firstLuminance = first.computeLuminance();
  final secondLuminance = second.computeLuminance();
  final lighter = firstLuminance > secondLuminance
      ? firstLuminance
      : secondLuminance;
  final darker = firstLuminance > secondLuminance
      ? secondLuminance
      : firstLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  const minTextContrast = 4.5;
  const minAccentContrast = 3.0;

  for (final brightness in Brightness.values) {
    for (final designSystem in DesignSystem.values) {
      final palette = DSTheme(
        brightness: brightness,
        designSystem: designSystem,
      ).colorPalette;
      final label = '${designSystem.name} ${brightness.name}';
      final brand = palette.brand;
      final semantic = palette.semantic;

      final textPairs = <String, (DSColor, DSColor)>{
        'onPrimary': (brand.primary, brand.onPrimary),
        'onPrimaryContainer': (
          brand.primaryContainer,
          brand.onPrimaryContainer,
        ),
        'onSecondary': (brand.secondary, brand.onSecondary),
        'onSecondaryContainer': (
          brand.secondaryContainer,
          brand.onSecondaryContainer,
        ),
        'onTertiary': (brand.tertiary, brand.onTertiary),
        'onTertiaryContainer': (
          brand.tertiaryContainer,
          brand.onTertiaryContainer,
        ),
        if (designSystem == DesignSystem.halloween) ...{
          'onTertiaryFixed': (brand.tertiaryFixed, brand.onTertiaryFixed),
          'onTertiaryFixedVariant': (
            brand.tertiaryFixedDim,
            brand.onTertiaryFixedVariant,
          ),
        },
        'onError': (semantic.error, semantic.onError),
        'onErrorContainer': (
          semantic.errorContainer,
          semantic.onErrorContainer,
        ),
        'onSurface': (palette.surface.surface, palette.surface.onSurface),
        'onSurfaceVariant': (
          palette.surface.surfaceVariant,
          palette.surface.onSurfaceVariant,
        ),
      };

      test('should keep text contrast of at least $minTextContrast '
          'when design system is $label', () {
        textPairs.forEach((name, pair) {
          expect(
            _contrast(pair.$1.color, pair.$2.color),
            greaterThanOrEqualTo(minTextContrast),
            reason: '$name in $label',
          );
        });
      });

      test('should keep accent contrast of at least $minAccentContrast '
          'against the surface when design system is $label', () {
        for (final accent in [brand.primary, brand.secondary, brand.tertiary]) {
          expect(
            _contrast(accent.color, palette.surface.surface.color),
            greaterThanOrEqualTo(minAccentContrast),
            reason: 'accent in $label',
          );
        }
      });
    }
  }
}
