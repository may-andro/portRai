import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSFloatingShapesBackgroundWidget',
    (theme) => [
      TestCase(
        'default shapes',
        SizedBox(
          width: 240,
          height: 160,
          child: DSFloatingShapesBackgroundWidget(
            color: theme.colorPalette.brand.primary.color,
          ),
        ),
      ),
      TestCase(
        'few shapes',
        SizedBox(
          width: 240,
          height: 160,
          child: DSFloatingShapesBackgroundWidget(
            color: theme.colorPalette.brand.tertiary.color,
            shapeCount: 5,
          ),
        ),
      ),
    ],
  );
}
