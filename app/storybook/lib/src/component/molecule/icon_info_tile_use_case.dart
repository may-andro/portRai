import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Icon Info Tile', type: DSIconInfoTileWidget)
Widget buildIconInfoTile(BuildContext context) {
  final icon = context.knobs.object.dropdown(
    label: 'Icon',
    options: [
      Icons.location_on_outlined,
      Icons.school_outlined,
      Icons.work_outline,
      Icons.language,
    ],
    labelBuilder: (icon) => icon.codePoint.toRadixString(16),
  );
  final isAnimated = context.knobs.boolean(
    label: 'Animated Icon',
    initialValue: false,
  );
  final label = context.knobs.string(label: 'Label', initialValue: 'LOCATION');
  final value = context.knobs.string(
    label: 'Value',
    initialValue: 'Amsterdam, NL',
  );

  return Center(
    child: DSIconInfoTileWidget(
      icon: icon,
      iconWidget: isAnimated
          ? const DSLottieIllustrationWidget(
              illustration: DSLottieIllustration.mapPin,
              width: 40,
            )
          : null,
      label: label,
      value: value,
      startColor: context.colorPalette.brand.primary,
      endColor: context.colorPalette.brand.tertiary,
      textColor: context.colorPalette.neutral.grey9,
    ),
  );
}
