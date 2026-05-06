import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSCardWidget',
    (theme) => [
      TestCase('default', DSCardWidget(child: _Content())),
      TestCase(
        'custom background',
        DSCardWidget(
          backgroundColor: theme.colorPalette.brand.primaryContainer,
          child: _Content(),
        ),
      ),
      TestCase(
        'elevated',
        DSCardWidget(elevation: theme.dimen.elevationLevel3, child: _Content()),
      ),
      TestCase(
        'circular radius',
        DSCardWidget(radius: theme.dimen.radiusCircular, child: _Content()),
      ),
      TestCase('tappable', DSCardWidget(onTap: () {}, child: _Content())),
      TestCase(
        'semi-transparent',
        DSCardWidget(backgroundColorOpacity: 0.4, child: _Content()),
      ),
    ],
  );
}

class _Content extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: DSTextWidget(
        'Card content',
        style: context.typography.bodyMedium,
        color: context.colorPalette.surface.onSurface,
      ),
    );
  }
}
