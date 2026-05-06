import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSDialogWidget',
    (theme) => [
      TestCase(
        'with text content',
        DSDialogWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                'Confirm Action',
                style: theme.typography.titleLarge,
                color: theme.colorPalette.neutral.grey9,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                'Are you sure you want to proceed?',
                style: theme.typography.bodyMedium,
                color: theme.colorPalette.neutral.grey7,
              ),
            ],
          ),
        ),
      ),
      TestCase(
        'with action buttons',
        DSDialogWidget(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                'Delete Item',
                style: theme.typography.titleLarge,
                color: theme.colorPalette.neutral.grey9,
              ),
              const DSVerticalSpacerWidget(1),
              DSTextWidget(
                'This action cannot be undone.',
                style: theme.typography.bodyMedium,
                color: theme.colorPalette.neutral.grey7,
              ),
              const DSVerticalSpacerWidget(2),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  DSButtonWidget(
                    label: 'Cancel',
                    onPressed: () {},
                    variant: DSButtonVariant.text,
                    size: DSButtonSize.small,
                  ),
                  const SizedBox(width: 8),
                  DSButtonWidget(
                    label: 'Delete',
                    onPressed: () {},
                    variant: DSButtonVariant.error,
                    size: DSButtonSize.small,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
