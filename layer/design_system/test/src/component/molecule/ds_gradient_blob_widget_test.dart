import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSGradientBlobWidget',
    (theme) => [
      TestCase(
        'purple blob',
        DSGradientBlobWidget(
          size: 120,
          colors: [
            theme.colorPalette.brand.primary.color,
            theme.colorPalette.brand.primary.color.withValues(alpha: 0),
          ],
          scaleBegin: const Offset(0.9, 0.9),
          scaleEnd: const Offset(1.1, 1.1),
          duration: const Duration(seconds: 3),
        ),
      ),
      TestCase(
        'secondary blob',
        DSGradientBlobWidget(
          size: 80,
          colors: [
            theme.colorPalette.brand.secondary.color,
            theme.colorPalette.brand.secondary.color.withValues(alpha: 0),
          ],
          scaleBegin: const Offset(1.0, 1.0),
          scaleEnd: const Offset(1.2, 1.2),
          duration: const Duration(seconds: 2),
        ),
      ),
    ],
  );
}
