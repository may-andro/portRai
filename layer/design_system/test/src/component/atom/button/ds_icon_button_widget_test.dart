import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSIconButtonWidget',
    (theme) => [
      // Sizes
      TestCase(
        'small',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
          onPressed: () {},
        ),
      ),
      TestCase(
        'medium',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
          size: DSIconButtonSize.medium,
          onPressed: () {},
        ),
      ),
      TestCase(
        'large',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
          size: DSIconButtonSize.large,
          onPressed: () {},
        ),
      ),
      // Disabled (no onPressed)
      TestCase(
        'disabled',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
        ),
      ),
      // Loading
      TestCase(
        'loading',
        DSIconButtonWidget(
          Icons.star,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.primary,
          isLoading: true,
          onPressed: () {},
        ),
      ),
      // With elevation
      TestCase(
        'with elevation',
        DSIconButtonWidget(
          Icons.favorite,
          iconColor: theme.colorPalette.brand.onPrimary,
          buttonColor: theme.colorPalette.brand.secondary,
          elevation: theme.dimen.elevationLevel2,
          onPressed: () {},
        ),
      ),
    ],
  );
}
