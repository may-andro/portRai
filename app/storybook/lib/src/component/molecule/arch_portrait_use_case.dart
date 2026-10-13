import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Arch Portrait', type: DSArchPortraitWidget)
Widget buildArchPortrait(BuildContext context) {
  final height = context.knobs.double.slider(
    label: 'Height',
    initialValue: 320,
    min: 160,
    max: 520,
  );

  return Center(
    child: DSArchPortraitWidget(
      height: height,
      gradientColors: [
        context.colorPalette.brand.primary.color,
        context.colorPalette.brand.tertiary.color,
      ],
      outlineColor: context.colorPalette.brand.secondaryContainer.color,
      child: AspectRatio(
        aspectRatio: 1,
        child: Icon(
          Icons.person,
          size: height * 0.7,
          color: context.colorPalette.neutral.grey9.color,
        ),
      ),
    ),
  );
}
