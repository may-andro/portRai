import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Spacer', type: DSVerticalSpacerWidget)
Widget buildSpacer(BuildContext context) {
  final factor = context.knobs.double.slider(
    label: 'Factor',
    initialValue: 1,
    min: 0.25,
    max: 4,
    divisions: 15,
  );
  
  final isVertical = context.knobs.boolean(label: 'Vertical', initialValue: true);
  
  if (isVertical) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DSTextWidget(
                'Item 1',
                color: context.colorPalette.neutral.grey9,
                style: context.typography.bodyLarge,
              ),
              DSVerticalSpacerWidget(factor),
              DSTextWidget(
                'Item 2',
                color: context.colorPalette.neutral.grey9,
                style: context.typography.bodyLarge,
              ),
              DSVerticalSpacerWidget(0.5),
              DSTextWidget(
                'Factor: ${factor.toStringAsFixed(2)}',
                color: context.colorPalette.neutral.grey7,
                style: context.typography.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  return Center(
    child: DSCardWidget(
      child: Padding(
        padding: EdgeInsets.all(context.space()),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                DSTextWidget(
                  'A',
                  color: context.colorPalette.neutral.grey9,
                  style: context.typography.bodyLarge,
                ),
                DSHorizontalSpacerWidget(factor),
                DSTextWidget(
                  'B',
                  color: context.colorPalette.neutral.grey9,
                  style: context.typography.bodyLarge,
                ),
              ],
            ),
            DSVerticalSpacerWidget(0.5),
            DSTextWidget(
              'Factor: ${factor.toStringAsFixed(2)}',
              color: context.colorPalette.neutral.grey7,
              style: context.typography.bodySmall,
            ),
          ],
        ),
      ),
    ),
  );
}
