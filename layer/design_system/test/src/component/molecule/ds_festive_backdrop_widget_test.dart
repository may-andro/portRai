import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSFestiveBackdropWidget',
    (theme) => [
      const TestCase(
        'circle',
        SizedBox(width: 160, height: 160, child: DSFestiveBackdropWidget()),
      ),
      TestCase(
        'rectangle',
        ColoredBox(
          color: theme.colorPalette.surface.inverseSurface.color,
          child: const SizedBox(
            width: 320,
            height: 120,
            child: DSFestiveBackdropWidget(
              shape: DSFestiveBackdropShape.rectangle,
              particleCount: 40,
            ),
          ),
        ),
      ),
    ],
  );
}
