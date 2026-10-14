import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSIconInfoTileWidget',
    (theme) => [
      TestCase(
        'location',
        DSIconInfoTileWidget(
          icon: Icons.location_on_outlined,
          label: 'LOCATION',
          value: 'Amsterdam, NL',
          startColor: theme.colorPalette.brand.primary,
          endColor: theme.colorPalette.brand.tertiary,
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
      TestCase(
        'education',
        DSIconInfoTileWidget(
          icon: Icons.school_outlined,
          label: 'EDUCATION',
          value: 'MSc Computer Science',
          startColor: theme.colorPalette.brand.tertiary,
          endColor: theme.colorPalette.brand.primary,
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
      TestCase(
        'animated location',
        DSIconInfoTileWidget(
          icon: Icons.location_on_outlined,
          iconWidget: const DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.mapPin,
            width: 40,
          ),
          label: 'LOCATION',
          value: 'Amsterdam, NL',
          startColor: theme.colorPalette.brand.primary,
          endColor: theme.colorPalette.brand.tertiary,
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
      TestCase(
        'animated education',
        DSIconInfoTileWidget(
          icon: Icons.school_outlined,
          iconWidget: const DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.graduationHat,
            width: 40,
          ),
          label: 'EDUCATION',
          value: 'MSc Computer Science',
          startColor: theme.colorPalette.brand.tertiary,
          endColor: theme.colorPalette.brand.primary,
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
    ],
  );
}
