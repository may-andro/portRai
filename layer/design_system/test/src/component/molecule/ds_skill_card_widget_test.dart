import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSSkillCardWidget',
    (theme) => [
      TestCase(
        'expert',
        SizedBox(
          width: 280,
          child: DSSkillCardWidget(
            name: 'Flutter',
            accent: theme.colorPalette.brand.primary.color,
            description: 'Widgets and tooling for polished apps.',
            levelLabel: 'Expert',
            progress: 1,
            animateProgress: false,
            details: '6 yrs · Last used 2026',
          ),
        ),
      ),
      TestCase(
        'intermediate',
        SizedBox(
          width: 280,
          child: DSSkillCardWidget(
            name: 'Kotlin',
            accent: theme.colorPalette.brand.tertiary.color,
            levelLabel: 'Intermediate',
            progress: 0.5,
            animateProgress: false,
            details: '3 yrs',
          ),
        ),
      ),
      TestCase(
        'name only',
        SizedBox(
          width: 280,
          child: DSSkillCardWidget(
            name: 'Swift',
            accent: theme.colorPalette.brand.secondary.color,
          ),
        ),
      ),
    ],
  );
}
