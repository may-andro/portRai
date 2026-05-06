import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSDetailSectionWidget',
    (theme) => [
      TestCase(
        'with text child',
        SizedBox(
          width: 300,
          child: DSDetailSectionWidget(
            title: 'Technologies',
            child: DSTextWidget(
              'Flutter, Dart, Firebase',
              style: theme.typography.bodyMedium,
              color: theme.colorPalette.neutral.grey8,
            ),
          ),
        ),
      ),
      const TestCase(
        'with tag list',
        SizedBox(
          width: 300,
          child: DSDetailSectionWidget(
            title: 'Skills',
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                DSTagWidget(label: 'Flutter'),
                DSTagWidget(label: 'Dart'),
                DSTagWidget(label: 'Firebase'),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}
