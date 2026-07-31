import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Divider', type: DSHorizontalDividerWidget)
Widget buildDivider(BuildContext context) {
  final thickness = context.knobs.int.slider(
    label: 'Thickness',
    initialValue: 1,
    min: 1,
    max: 8,
  );
  
  final isVertical = context.knobs.boolean(label: 'Vertical', initialValue: false);
  
  final colorMap = {
    ...context.brandColorsMap,
    'Outline': context.colorPalette.outline.outline,
    'Outline Variant': context.colorPalette.outline.outlineVariant,
    'Grey 5': context.colorPalette.neutral.grey5,
  };
  
  final selectedColorName = context.knobs.object.dropdown(
    label: 'Color',
    options: colorMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  
  final selectedColor = colorMap[selectedColorName]!;
  
  if (isVertical) {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DSTextWidget(
            'Left',
            color: context.colorPalette.neutral.grey9,
            style: context.typography.bodyLarge,
          ),
          DSHorizontalSpacerWidget(1),
          SizedBox(
            height: 100,
            child: DSVerticalDividerWidget(
              thickness: thickness.toDouble(),
              color: selectedColor,
            ),
          ),
          DSHorizontalSpacerWidget(1),
          DSTextWidget(
            'Right',
            color: context.colorPalette.neutral.grey9,
            style: context.typography.bodyLarge,
          ),
        ],
      ),
    );
  }
  
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        DSTextWidget(
          'Content Above',
          color: context.colorPalette.neutral.grey9,
          style: context.typography.bodyLarge,
        ),
        DSVerticalSpacerWidget(1),
        DSHorizontalDividerWidget(
          thickness: thickness.toDouble(),
          color: selectedColor,
        ),
        DSVerticalSpacerWidget(1),
        DSTextWidget(
          'Content Below',
          color: context.colorPalette.neutral.grey9,
          style: context.typography.bodyLarge,
        ),
      ],
    ),
  );
}
