import 'package:design_system/src/foundation/typography/ds_text_style.dart';

abstract interface class DSTypography {
  const DSTypography();

  DSTextStyle get displayLarge;

  DSTextStyle get displayMedium;

  DSTextStyle get displaySmall;

  DSTextStyle get emphasizedDisplayLarge;

  DSTextStyle get emphasizedDisplayMedium;

  DSTextStyle get emphasizedDisplaySmall;

  DSTextStyle get headlineLarge;

  DSTextStyle get headlineMedium;

  DSTextStyle get headlineSmall;

  DSTextStyle get emphasizedHeadlineLarge;

  DSTextStyle get emphasizedHeadlineMedium;

  DSTextStyle get emphasizedHeadlineSmall;

  DSTextStyle get titleLarge;

  DSTextStyle get titleMedium;

  DSTextStyle get titleSmall;

  DSTextStyle get emphasizedTitleLarge;

  DSTextStyle get emphasizedTitleMedium;

  DSTextStyle get emphasizedTitleSmall;

  DSTextStyle get bodyLarge;

  DSTextStyle get bodyMedium;

  DSTextStyle get bodySmall;

  DSTextStyle get emphasizedBodyLarge;

  DSTextStyle get emphasizedBodyMedium;

  DSTextStyle get emphasizedBodySmall;

  DSTextStyle get labelLarge;

  DSTextStyle get labelMedium;

  DSTextStyle get labelSmall;

  DSTextStyle get emphasizedLabelLarge;

  DSTextStyle get emphasizedLabelMedium;

  DSTextStyle get emphasizedLabelSmall;
}
