import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSArchPortraitWidget',
    (theme) => [
      TestCase(
        'portrait',
        DSArchPortraitWidget(
          height: 220,
          gradientColors: [
            theme.colorPalette.brand.primary.color,
            theme.colorPalette.brand.tertiary.color,
          ],
          outlineColor: theme.colorPalette.brand.secondaryContainer.color,
          child: AspectRatio(
            aspectRatio: 1,
            child: Icon(
              Icons.person,
              size: 160,
              color: theme.colorPalette.neutral.grey9.color,
            ),
          ),
        ),
      ),
    ],
  );
}
