import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Icon', type: DSIconWidget)
Widget buildIcon(BuildContext context) {
  final selectedIcon = context.knobs.object.dropdown(
    label: 'Icon',
    options: CommonIcons.commonIcons,
    labelBuilder: (icon) => icon.toString().split('.').last,
  );

  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: DSIconSize.values,
    labelBuilder: (value) => value.name,
  );

  final colorMap = context.semanticColorsMap;
  final selectedColorName = context.knobs.object.dropdown(
    label: 'Color',
    options: colorMap.keys.toList(),
    labelBuilder: (name) => name,
  );

  final selectedColor = colorMap[selectedColorName]!;

  return Center(
    child: DSIconWidget(selectedIcon, color: selectedColor, size: size),
  );
}
