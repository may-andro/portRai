import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSAvailabilityBadgeWidget',
    (theme) => [
      TestCase(
        'available',
        DSAvailabilityBadgeWidget(
          label: 'Available for work · Full-time',
          color: const Color(0xFF22C55E),
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
      TestCase(
        'brand colored',
        DSAvailabilityBadgeWidget(
          label: 'Open to freelance',
          color: theme.colorPalette.brand.primary.color,
          textColor: theme.colorPalette.neutral.grey9,
        ),
      ),
    ],
  );
}
