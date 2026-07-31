import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Card', type: DSCardWidget)
Widget buildCard(BuildContext context) {
  final elevationMap = context.elevationOptionsMap;
  final selectedElevationName = context.knobs.object.dropdown(
    label: 'Elevation',
    options: elevationMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  final selectedElevation = elevationMap[selectedElevationName]!;
  
  final radiusMap = context.radiusOptionsMap;
  final selectedRadiusName = context.knobs.object.dropdown(
    label: 'Radius',
    options: radiusMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  final selectedRadius = radiusMap[selectedRadiusName]!;
  
  final backgroundColorMap = context.containerColorsMap;
  final selectedBackgroundName = context.knobs.object.dropdown(
    label: 'Background Color',
    options: backgroundColorMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  final selectedBackground = backgroundColorMap[selectedBackgroundName];
  
  final isClickable = context.knobs.boolean(label: 'Clickable', initialValue: false);
  
  final hasIcon = context.knobs.boolean(label: 'Has Icon', initialValue: false);
  
  final cardTitle = context.knobs.string(label: 'Title', initialValue: 'Card Title');
  
  final cardDescription = context.knobs.string(
    label: 'Description',
    initialValue: 'This is a card widget with customizable properties.',
  );
  
  return Center(
    child: DSCardWidget(
      elevation: selectedElevation,
      radius: selectedRadius,
      backgroundColor: selectedBackground,
      onTap: isClickable ? () {} : null,
      child: Padding(
        padding: EdgeInsets.all(context.space()),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasIcon) ...[
              DSIconWidget(
                Icons.credit_card,
                color: context.getContainerTextColor(selectedBackground),
                size: DSIconSize.large,
              ),
              DSHorizontalSpacerWidget(1),
            ],
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DSTextWidget(
                    cardTitle,
                    color: context.getContainerTextColor(selectedBackground),
                    style: context.typography.titleLarge,
                  ),
                  DSVerticalSpacerWidget(0.5),
                  DSTextWidget(
                    cardDescription,
                    color: selectedBackground != null
                        ? context.getContainerTextColor(selectedBackground)
                        : context.colorPalette.neutral.grey7,
                    style: context.typography.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
