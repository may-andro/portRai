import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSExpandableCardWidget',
    (theme) => [
      TestCase(
        'collapsed',
        SizedBox(
          width: 300,
          child: DSExpandableCardWidget(
            headerContent: DSTextWidget(
              'What is Flutter?',
              style: theme.typography.titleMedium,
              color: theme.colorPalette.surface.onSurface,
            ),
            expandedContent: DSTextWidget(
              'Flutter is an open-source UI toolkit by Google.',
              style: theme.typography.bodyMedium,
              color: theme.colorPalette.neutral.grey8,
            ),
          ),
        ),
      ),
    ],
  );
}
