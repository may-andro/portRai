import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// Halloween Typography
/// Spooky and playful typography with gothic flair
/// Optimized for Halloween themes with eerie elegance and excellent readability
class HalloweenTypography implements DSTypography {
  const HalloweenTypography();

  // Display styles - for large, spooky headlines
  @override
  DSTextStyle get displayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w400,
    height: 1.10,
    letterSpacing: -0.5,
  );

  @override
  DSTextStyle get displayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w400,
    height: 1.14,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get displaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    height: 1.20,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedDisplayLarge => const DSTextStyle(
    fontSize: 57,
    fontWeight: FontWeight.w800,
    height: 1.10,
    letterSpacing: -0.5,
  );

  @override
  DSTextStyle get emphasizedDisplayMedium => const DSTextStyle(
    fontSize: 45,
    fontWeight: FontWeight.w800,
    height: 1.14,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get emphasizedDisplaySmall => const DSTextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w800,
    height: 1.20,
    letterSpacing: 0,
  );

  // Headline styles - for haunting event titles
  @override
  DSTextStyle get headlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w400,
    height: 1.22,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get headlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w400,
    height: 1.26,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get headlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w400,
    height: 1.30,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineLarge => const DSTextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 1.22,
    letterSpacing: -0.25,
  );

  @override
  DSTextStyle get emphasizedHeadlineMedium => const DSTextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.26,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedHeadlineSmall => const DSTextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.30,
    letterSpacing: 0,
  );

  // Title styles - for spooky sections and scary categories
  @override
  DSTextStyle get titleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w400,
    height: 1.25,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get titleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.48,
    letterSpacing: 0.2,
  );

  @override
  DSTextStyle get titleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.40,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get emphasizedTitleLarge => const DSTextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    height: 1.25,
    letterSpacing: 0,
  );

  @override
  DSTextStyle get emphasizedTitleMedium => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    height: 1.48,
    letterSpacing: 0.2,
  );

  @override
  DSTextStyle get emphasizedTitleSmall => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    height: 1.40,
    letterSpacing: 0.15,
  );

  // Body styles - for ghost stories and spooky content
  @override
  DSTextStyle get bodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.48,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get bodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.40,
    letterSpacing: 0.3,
  );

  @override
  DSTextStyle get bodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.30,
    letterSpacing: 0.4,
  );

  @override
  DSTextStyle get emphasizedBodyLarge => const DSTextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.48,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedBodyMedium => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.40,
    letterSpacing: 0.3,
  );

  @override
  DSTextStyle get emphasizedBodySmall => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: 0.4,
  );

  // Label styles - for eerie elements and haunted navigation
  @override
  DSTextStyle get labelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.40,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get labelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.30,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get labelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    height: 1.42,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelLarge => const DSTextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w800,
    height: 1.40,
    letterSpacing: 0.15,
  );

  @override
  DSTextStyle get emphasizedLabelMedium => const DSTextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    height: 1.30,
    letterSpacing: 0.5,
  );

  @override
  DSTextStyle get emphasizedLabelSmall => const DSTextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w800,
    height: 1.42,
    letterSpacing: 0.5,
  );
}
