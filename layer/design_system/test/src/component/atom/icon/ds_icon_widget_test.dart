import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSIconWidget',
    (theme) => [
      TestCase(
        'small',
        DSIconWidget(
          Icons.star,
          size: DSIconSize.small,
          color: theme.colorPalette.brand.primary,
        ),
      ),
      TestCase(
        'medium',
        DSIconWidget(
          Icons.star,
          size: DSIconSize.medium,
          color: theme.colorPalette.brand.primary,
        ),
      ),
      TestCase(
        'large',
        DSIconWidget(
          Icons.star,
          size: DSIconSize.large,
          color: theme.colorPalette.brand.primary,
        ),
      ),
      TestCase(
        'secondary color',
        DSIconWidget(
          Icons.favorite,
          size: DSIconSize.medium,
          color: theme.colorPalette.brand.secondary,
        ),
      ),
      TestCase(
        'error color',
        DSIconWidget(
          Icons.error_outline,
          size: DSIconSize.medium,
          color: theme.colorPalette.semantic.error,
        ),
      ),
    ],
  );
}

