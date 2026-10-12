import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

final dsProgressRing = CatalogItem(
  name: 'DSProgressRing',
  dataSchema: S.object(
    description:
        'A circular gauge for one highlighted value out of 100, for example '
        'proficiency or a completion rate.',
    properties: {
      'value': S.number(description: 'From 0 to 100.'),
      'label': S.string(description: 'Short caption under the ring.'),
      'display': S.string(description: 'Text in the ring, for example 90%.'),
    },
    required: ['value'],
  ),
  widgetBuilder: (itemContext) {
    final data = itemContext.data as JsonMap;
    final value = data['value'];
    if (value is! num) return const SizedBox.shrink();
    final fraction = (value / 100).clamp(0.0, 1.0);
    final display = data['display'] as String? ?? '${value.round()}%';
    final label = data['label'] as String?;
    return Builder(
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.5),
        children: [
          SizedBox.square(
            dimension: context.space(factor: 9),
            child: Stack(
              fit: StackFit.expand,
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: fraction,
                  strokeWidth: context.space(),
                  backgroundColor: context.colorPalette.neutral.grey3.color,
                  color: context.colorPalette.brand.primary.color,
                ),
                Center(
                  child: DSTextWidget(
                    display,
                    style: context.typography.emphasizedTitleMedium,
                    color: context.colorPalette.neutral.grey9,
                  ),
                ),
              ],
            ),
          ),
          if (label != null)
            DSTextWidget(
              label,
              style: context.typography.labelMedium,
              color: context.colorPalette.neutral.grey7,
            ),
        ],
      ),
    );
  },
);
