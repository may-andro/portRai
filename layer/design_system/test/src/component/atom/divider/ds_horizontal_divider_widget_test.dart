import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSHorizontalDividerWidget',
    (theme) => [
      TestCase(
        'thin',
        SizedBox(
          width: 200,
          child: DSHorizontalDividerWidget(
            thickness: 1,
            color: theme.colorPalette.neutral.grey5,
          ),
        ),
      ),
      TestCase(
        'thick',
        SizedBox(
          width: 200,
          child: DSHorizontalDividerWidget(
            thickness: 4,
            color: theme.colorPalette.neutral.grey5,
          ),
        ),
      ),
      TestCase(
        'primary color',
        SizedBox(
          width: 200,
          child: DSHorizontalDividerWidget(
            thickness: 2,
            color: theme.colorPalette.brand.primary,
          ),
        ),
      ),
    ],
  );
}
