import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// Pachamama Typography
/// Grounded and nurturing typography with Andean earth connection
/// Optimized for Mother Earth festival themes with natural strength and excellent readability
class PachamamaTypography implements DSTypography {
  const PachamamaTypography();

  // Display styles - for large, grounding earth headlines
  @override
  DSTextStyle get displayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.20,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get displayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.24,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get displaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.28,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedDisplayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w600,
    height: 1.20,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get emphasizedDisplayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w600,
    height: 1.24,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedDisplaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w600,
    height: 1.28,
    letterSpacing: 0,
  );

  // Headline styles - for sacred earth ceremony titles
  @override
  DSTextStyle get headlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.34,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get headlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.38,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get headlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.42,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w600,
    height: 1.34,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    height: 1.38,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.42,
    letterSpacing: 0,
  );

  // Title styles - for earth connection sections and harvest categories
  @override
  DSTextStyle get titleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.36,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get titleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.60,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get titleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.52,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get emphasizedTitleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.36,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedTitleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.60,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get emphasizedTitleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.52,
    letterSpacing: 0.1,
  );

  // Body styles - for earth wisdom and sacred content
  @override
  DSTextStyle get bodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.60,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get bodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.52,
    letterSpacing: 0.25,
  );

  @override
  DSTextStyle get bodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.44,
    letterSpacing: 0.4,
  );

  @override
  DSTextStyle get emphasizedBodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.60,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedBodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.52,
    letterSpacing: 0.25,
  );

  @override
  DSTextStyle get emphasizedBodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.44,
    letterSpacing: 0.4,
  );

  // Label styles - for earth elements and natural navigation
  @override
  DSTextStyle get labelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    height: 1.52,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get labelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.44,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get labelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.54,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.52,
    letterSpacing: 0.1,
  );

  @override
  DSTextStyle get emphasizedLabelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.44,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.54,
    letterSpacing: 0.5,
  );
}
