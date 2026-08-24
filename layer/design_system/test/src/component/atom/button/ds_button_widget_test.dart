import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSButtonWidget',
    (theme) => [
      // Variants
      TestCase('primary', DSButtonWidget(label: 'Primary', onPressed: () {})),
      TestCase(
        'secondary',
        DSButtonWidget(
          label: 'Secondary',
          onPressed: () {},
          variant: DSButtonVariant.secondary,
        ),
      ),
      TestCase(
        'error',
        DSButtonWidget(
          label: 'Error',
          onPressed: () {},
          variant: DSButtonVariant.error,
        ),
      ),
      TestCase(
        'text',
        DSButtonWidget(
          label: 'Text',
          onPressed: () {},
          variant: DSButtonVariant.text,
        ),
      ),
      // Borders
      TestCase(
        'rounded border',
        DSButtonWidget(
          label: 'Rounded',
          onPressed: () {},
          border: DSButtonBorder.rounded,
        ),
      ),
      // Sizes
      TestCase(
        'extra small',
        DSButtonWidget(
          label: 'Extra Small',
          onPressed: () {},
          size: DSButtonSize.extraSmall,
        ),
      ),
      TestCase(
        'small',
        DSButtonWidget(
          label: 'Small',
          onPressed: () {},
          size: DSButtonSize.small,
        ),
      ),
      TestCase(
        'medium',
        DSButtonWidget(
          label: 'Medium',
          onPressed: () {},
          size: DSButtonSize.medium,
        ),
      ),
      TestCase('large', DSButtonWidget(label: 'Large', onPressed: () {})),
      // Icons
      TestCase(
        'icon left',
        DSButtonWidget(label: 'Icon Left', onPressed: () {}, icon: Icons.star),
      ),
      TestCase(
        'icon right',
        DSButtonWidget(
          label: 'Icon Right',
          onPressed: () {},
          icon: Icons.star,
          iconDirection: DSButtonIconDirection.right,
        ),
      ),
      // States
      TestCase(
        'disabled',
        DSButtonWidget(label: 'Disabled', onPressed: () {}, isDisabled: true),
      ),
      TestCase(
        'loading',
        DSButtonWidget(label: 'Loading', onPressed: () {}, isLoading: true),
      ),
    ],
  );
}
