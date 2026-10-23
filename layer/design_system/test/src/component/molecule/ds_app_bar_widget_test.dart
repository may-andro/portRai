import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  // The golden pumps are short, so the logo animation is loaded up front and
  // the first golden doesn't render before it is ready.
  setUpAll(() async {
    await AssetLottie(Assets.lottie.logo.path, package: 'design_system').load();
  });

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
