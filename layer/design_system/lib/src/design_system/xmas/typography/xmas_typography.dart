import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// Christmas Typography
/// Festive and warm typography with holiday celebration spirit
/// Optimized for Christmas themes with joyful elegance and excellent readability
class ChristmasTypography implements DSTypography {
  const ChristmasTypography();

  // Display styles - for large, festive holiday headlines
  @override
  DSTextStyle get displayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.12,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get displayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.16,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get displaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.22,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedDisplayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w600,
    height: 1.12,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get emphasizedDisplayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.16,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedDisplaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.22,
    letterSpacing: 0,
  );

  // Headline styles - for Christmas celebration titles
  @override
  DSTextStyle get headlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get headlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.29,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get headlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.25,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.29,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0,
  );

  // Title styles - for holiday sections and Christmas categories
  @override
  DSTextStyle get titleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.27,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get titleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.50,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get titleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get emphasizedTitleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.27,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedTitleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.50,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get emphasizedTitleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  // Body styles - for Christmas stories and holiday content
  @override
  DSTextStyle get bodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.50,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get bodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.43,
    letterSpacing: 0.25,
  );

  @override
  DSTextStyle get bodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.33,
    letterSpacing: 0.4,
  );

  @override
  DSTextStyle get emphasizedBodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.50,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedBodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.25,
  );

  @override
  DSTextStyle get emphasizedBodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.4,
  );

  // Label styles - for festive elements and holiday navigation
  @override
  DSTextStyle get labelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.43,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get labelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.33,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get labelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.45,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.43,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get emphasizedLabelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.33,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.45,
    letterSpacing: 0.5,
  );
}
