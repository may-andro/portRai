import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSTagWidget',
    (theme) => [
      const TestCase('short label', DSTagWidget(label: 'Dart')),
      const TestCase('long label', DSTagWidget(label: 'Machine Learning')),
      const TestCase(
        'multiple tags',
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            DSTagWidget(label: 'Flutter'),
            DSTagWidget(label: 'Firebase'),
            DSTagWidget(label: 'REST API'),
            DSTagWidget(label: 'CI/CD'),
          ],
        ),
      ),
    ],
  );
}
