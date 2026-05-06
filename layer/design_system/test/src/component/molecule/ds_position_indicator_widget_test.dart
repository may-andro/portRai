import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSPositionIndicatorWidget',
    (theme) => [
      TestCase(
        '3 items index 0',
        SizedBox(
          width: 200,
          child: DSPositionIndicatorWidget(
            itemCount: 3,
            indexListener: ValueNotifier<int>(0),
          ),
        ),
      ),
      TestCase(
        '5 items index 2',
        SizedBox(
          width: 200,
          child: DSPositionIndicatorWidget(
            itemCount: 5,
            indexListener: ValueNotifier<int>(2),
          ),
        ),
      ),
    ],
  );
}
