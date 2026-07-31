import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Button', type: DSButtonWidget)
Widget buildButton(BuildContext context) {
  final variant = context.knobs.object.dropdown(
    label: 'Variant',
    options: DSButtonVariant.values,
    labelBuilder: (value) => value.name,
  );
  
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: DSButtonSize.values,
    labelBuilder: (value) => value.name,
  );
  
  final border = context.knobs.object.dropdown(
    label: 'Border',
    options: DSButtonBorder.values,
    labelBuilder: (value) => value.name,
  );
  
  final isDisabled = context.knobs.boolean(label: 'Disabled', initialValue: false);
  final isLoading = context.knobs.boolean(label: 'Loading', initialValue: false);
  
  final hasIcon = context.knobs.boolean(label: 'Has Icon', initialValue: false);
  
  final iconDirection = context.knobs.object.dropdown(
    label: 'Icon Direction',
    options: DSButtonIconDirection.values,
    labelBuilder: (value) => value.name,
  );
  
  final label = context.knobs.string(label: 'Label', initialValue: 'Button');
  
  return Center(
    child: DSButtonWidget(
      label: label,
      onPressed: () {},
      variant: variant,
      size: size,
      border: border,
      isDisabled: isDisabled,
      isLoading: isLoading,
      icon: hasIcon ? Icons.star : null,
      iconDirection: iconDirection,
    ),
  );
}

@UseCase(name: 'Icon Button', type: DSIconButtonWidget)
Widget buildIconButton(BuildContext context) {
  final selectedIcon = context.knobs.object.dropdown(
    label: 'Icon',
    options: CommonIcons.commonIcons.take(10).toList(),
    labelBuilder: (icon) => icon.toString().split('.').last,
  );
  
  final size = context.knobs.object.dropdown(
    label: 'Size',
    options: DSIconButtonSize.values,
    labelBuilder: (value) => value.name,
  );
  
  final buttonColorMap = context.brandColorsMap;
  final buttonColorName = context.knobs.object.dropdown(
    label: 'Button Color',
    options: buttonColorMap.keys.toList(),
    labelBuilder: (name) => name,
    initialOption: 'Primary',
  );
  final buttonColor = buttonColorMap[buttonColorName]!;
  
  final iconColorMap = context.brandColorsMap;
  final iconColorName = context.knobs.object.dropdown(
    label: 'Icon Color',
    options: iconColorMap.keys.toList(),
    labelBuilder: (name) => name,
    initialOption: 'On Primary',
  );
  final iconColor = iconColorMap[iconColorName]!;
  
  final isLoading = context.knobs.boolean(label: 'Loading', initialValue: false);
  
  return Center(
    child: DSIconButtonWidget(
      selectedIcon,
      iconColor: iconColor,
      buttonColor: buttonColor,
      size: size,
      isLoading: isLoading,
      onPressed: () {},
    ),
  );
}
