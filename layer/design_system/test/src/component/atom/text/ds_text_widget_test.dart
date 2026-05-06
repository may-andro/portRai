import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSTextWidget',
    (theme) => [
      // Scale
      TestCase(
        'displayLarge',
        DSTextWidget(
          'Display Large',
          style: theme.typography.displayLarge,
          color: theme.colorPalette.surface.onSurface,
        ),
      ),
      TestCase(
        'titleLarge',
        DSTextWidget(
          'Title Large',
          style: theme.typography.titleLarge,
          color: theme.colorPalette.surface.onSurface,
        ),
      ),
      TestCase(
        'bodyMedium',
        DSTextWidget(
          'Body Medium',
          style: theme.typography.bodyMedium,
          color: theme.colorPalette.surface.onSurface,
        ),
      ),
      TestCase(
        'labelSmall',
        DSTextWidget(
          'Label Small',
          style: theme.typography.labelSmall,
          color: theme.colorPalette.surface.onSurface,
        ),
      ),
      // Style modifiers
      TestCase(
        'emphasized',
        DSTextWidget(
          'Emphasized Body',
          style: theme.typography.emphasizedBodyMedium,
          color: theme.colorPalette.surface.onSurface,
        ),
      ),
      TestCase(
        'italic',
        DSTextWidget(
          'Italic Body',
          style: theme.typography.bodyMedium,
          color: theme.colorPalette.surface.onSurface,
          isItalic: true,
        ),
      ),
      TestCase(
        'underline',
        DSTextWidget(
          'Underlined',
          style: theme.typography.bodyMedium,
          color: theme.colorPalette.brand.primary,
          decoration: TextDecoration.underline,
        ),
      ),
      TestCase(
        'truncated',
        SizedBox(
          width: 120,
          child: DSTextWidget(
            'This text is too long to fit in one line',
            style: theme.typography.bodyMedium,
            color: theme.colorPalette.surface.onSurface,
            maxLines: 1,
            textOverflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ],
  );
}

