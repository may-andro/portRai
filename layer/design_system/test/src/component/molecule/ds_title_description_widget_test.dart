import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSTitleDescriptionWidget',
    (theme) => [
      const TestCase(
        'left aligned',
        SizedBox(
          width: 280,
          child: DSTitleDescriptionWidget(
            title: 'Mobile Development',
            description: 'Building cross-platform apps with Flutter and Dart.',
            titleMaxLines: 1,
            descriptionMaxLines: 2,
          ),
        ),
      ),
      const TestCase(
        'centered',
        SizedBox(
          width: 280,
          child: DSTitleDescriptionWidget(
            title: 'Mobile Development',
            description: 'Building cross-platform apps with Flutter and Dart.',
            titleMaxLines: 1,
            descriptionMaxLines: 2,
            isCenteredContent: true,
          ),
        ),
      ),
      const TestCase(
        'long title truncated',
        SizedBox(
          width: 200,
          child: DSTitleDescriptionWidget(
            title: 'Cross-Platform Mobile Application Development',
            description: 'Flutter, Dart, iOS, Android.',
            titleMaxLines: 1,
            descriptionMaxLines: 1,
          ),
        ),
      ),
    ],
  );
}
