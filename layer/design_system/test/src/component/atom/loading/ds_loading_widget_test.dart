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
      TestCase(
        'small size',
        const SizedBox(
          width: 80,
          height: 40,
          child: DSLoadingWidget(size: 24),
        ),
      ),
      TestCase(
        'large size',
        const SizedBox(
          width: 160,
          height: 80,
          child: DSLoadingWidget(size: 60),
        ),
      ),
    ],
  );
}

