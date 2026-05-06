import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../../../util/alchemist_utils.dart';

void main() {
  groupGoldenForBrightnessAndDS(
    'DSStaggeredGridWidget',
    (theme) => [
      TestCase(
        '2 columns',
        SizedBox(
          width: 320,
          height: 320,
          child: DSStaggeredGridWidget(
            crossAxisCount: 2,
            itemCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            itemBuilder: (context, index) => Container(
              height: 60.0 + (index % 2) * 30,
              decoration: BoxDecoration(
                color: theme.colorPalette.brand.primaryContainer.color,
                borderRadius: BorderRadius.circular(
                  theme.dimen.radiusLevel2.value,
                ),
              ),
              child: Center(
                child: DSTextWidget(
                  'Item ${index + 1}',
                  style: theme.typography.labelMedium,
                  color: theme.colorPalette.brand.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
      TestCase(
        '3 columns',
        SizedBox(
          width: 360,
          height: 320,
          child: DSStaggeredGridWidget(
            crossAxisCount: 3,
            itemCount: 6,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            itemBuilder: (context, index) => Container(
              height: 50.0 + (index % 3) * 20,
              decoration: BoxDecoration(
                color: theme.colorPalette.brand.secondaryContainer.color,
                borderRadius: BorderRadius.circular(
                  theme.dimen.radiusLevel2.value,
                ),
              ),
              child: Center(
                child: DSTextWidget(
                  '${index + 1}',
                  style: theme.typography.labelMedium,
                  color: theme.colorPalette.brand.onSecondaryContainer,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}
