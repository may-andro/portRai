import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSAppBarWidget',
    (theme) => [
      const TestCase(
        'default',
        SizedBox(height: 64, child: DSAppBarWidget(height: 64)),
      ),
      TestCase(
        'with back button',
        SizedBox(
          height: 64,
          child: DSAppBarWidget(height: 64, onBackClicked: () {}),
        ),
      ),
      TestCase(
        'with action',
        SizedBox(
          height: 64,
          child: DSAppBarWidget(
            height: 64,
            actions: [
              Icon(
                Icons.settings,
                color: theme.colorPalette.surface.onSurface.color,
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
