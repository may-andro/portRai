import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Loading', type: DSLoadingWidget)
Widget buildLoading(BuildContext context) {
  final size = context.knobs.int.slider(
    label: 'Size',
    initialValue: 40,
    min: 20,
    max: 100,
  );
  
  final colorMap = {
    ...context.brandColorsMap,
    ...context.semanticColorsMap,
  };
  
  final selectedColorName = context.knobs.object.dropdown(
    label: 'Color',
    options: colorMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  
  final selectedColor = colorMap[selectedColorName]!;
  
  final inCard = context.knobs.boolean(label: 'Show in Card', initialValue: false);
  
  final loadingWidget = DSLoadingWidget(
    size: size.toDouble(),
    color: selectedColor,
  );
  
  if (inCard) {
    return Center(
      child: DSCardWidget(
        child: Container(
          height: 200,
          padding: EdgeInsets.all(context.space()),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              loadingWidget,
              DSVerticalSpacerWidget(1),
              DSTextWidget(
                'Loading...',
                color: context.colorPalette.neutral.grey7,
                style: context.typography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  return Center(child: loadingWidget);
}
