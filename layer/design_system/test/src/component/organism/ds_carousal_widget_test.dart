import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSCarousalWidget',
    (theme) => [
      TestCase(
        'single item',
        SizedBox(
          width: 300,
          child: DSCarousalWidget(
            height: 120,
            children: [
              ColoredBox(
                color: theme.colorPalette.brand.primaryContainer.color,
                child: Center(
                  child: DSTextWidget(
                    'Slide 1',
                    style: theme.typography.titleMedium,
                    color: theme.colorPalette.brand.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      TestCase(
        'multiple items',
        SizedBox(
          width: 300,
          child: DSCarousalWidget(
            height: 120,
            viewportFraction: 0.85,
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: theme.colorPalette.brand.primaryContainer.color,
                child: Center(
                  child: DSTextWidget(
                    'Slide 1',
                    style: theme.typography.titleMedium,
                    color: theme.colorPalette.brand.onPrimaryContainer,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: theme.colorPalette.brand.secondaryContainer.color,
                child: Center(
                  child: DSTextWidget(
                    'Slide 2',
                    style: theme.typography.titleMedium,
                    color: theme.colorPalette.brand.onSecondaryContainer,
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color: theme.colorPalette.brand.tertiaryContainer.color,
                child: Center(
                  child: DSTextWidget(
                    'Slide 3',
                    style: theme.typography.titleMedium,
                    color: theme.colorPalette.brand.onTertiaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
