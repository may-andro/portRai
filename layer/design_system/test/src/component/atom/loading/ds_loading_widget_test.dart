import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSLoadingWidget',
    (theme) => [
      TestCase(
        'default (primary color)',
        const SizedBox(
          width: 120,
          height: 60,
          child: DSLoadingWidget(size: 40),
        ),
      ),
      TestCase(
        'custom color',
        SizedBox(
          width: 120,
          height: 60,
          child: DSLoadingWidget(
            size: 40,
            color: theme.colorPalette.brand.secondary,
          ),
        ),
      ),
      const TestCase(
        'small size',
        SizedBox(width: 80, height: 40, child: DSLoadingWidget(size: 24)),
      ),
      const TestCase(
        'large size',
        SizedBox(
          width: 160,
          height: 80,
          child: DSLoadingWidget(size: 60),
        ),
      ),
    ],
  );
}
