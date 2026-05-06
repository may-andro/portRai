import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSVerticalDividerWidget',
    (theme) => [
      TestCase(
        'thin',
        SizedBox(
          height: 60,
          child: DSVerticalDividerWidget(
            thickness: 1,
            color: theme.colorPalette.neutral.grey5,
          ),
        ),
      ),
      TestCase(
        'thick',
        SizedBox(
          height: 60,
          child: DSVerticalDividerWidget(
            thickness: 4,
            color: theme.colorPalette.neutral.grey5,
          ),
        ),
      ),
      TestCase(
        'primary color',
        SizedBox(
          height: 60,
          child: DSVerticalDividerWidget(
            thickness: 2,
            color: theme.colorPalette.brand.primary,
          ),
        ),
      ),
    ],
  );
}
