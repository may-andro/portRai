import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSInfoChipWidget',
    (theme) => [
      const TestCase(
        'date',
        DSInfoChipWidget(icon: Icons.calendar_today, label: 'Jan 2023'),
      ),
      const TestCase(
        'location',
        DSInfoChipWidget(icon: Icons.location_on, label: 'Remote'),
      ),
      const TestCase(
        'role',
        DSInfoChipWidget(icon: Icons.work_outline, label: 'Full-time'),
      ),
    ],
  );
}
