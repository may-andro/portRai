import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSSpotlightCardWidget',
    (theme) => [
      TestCase(
        'with content',
        SizedBox(
          width: 260,
          child: DSSpotlightCardWidget(
            glowColor: theme.colorPalette.brand.primary,
            fillColor: theme.colorPalette.surface.onInverseSurface,
            builder: (context, isHovering) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DSTextWidget(
                  'Mobile Development',
                  style: theme.typography.titleLarge,
                  color: theme.colorPalette.neutral.grey9,
                ),
                const DSVerticalSpacerWidget(1),
                DSTextWidget(
                  'Cross-platform apps that feel native.',
                  style: theme.typography.bodyMedium,
                  color: theme.colorPalette.neutral.grey7,
                ),
              ],
            ),
          ),
        ),
      ),
      TestCase(
        'with background',
        SizedBox(
          width: 260,
          height: 140,
          child: DSSpotlightCardWidget(
            glowColor: theme.colorPalette.brand.tertiary,
            fillColor: theme.colorPalette.surface.onInverseSurface,
            background: Align(
              alignment: Alignment.bottomRight,
              child: Icon(
                Icons.phone_iphone,
                size: 80,
                color: theme.colorPalette.brand.primary.color.withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            builder: (context, isHovering) => DSTextWidget(
              'Web Apps',
              style: theme.typography.titleLarge,
              color: theme.colorPalette.neutral.grey9,
            ),
          ),
        ),
      ),
    ],
  );
}
