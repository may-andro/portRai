import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Tag', type: DSTagWidget)
Widget buildTag(BuildContext context) {
  final label = context.knobs.string(label: 'Label', initialValue: 'Flutter');

  final showMultiple = context.knobs.boolean(
    label: 'Show Multiple',
    initialValue: false,
  );

  final inCard = context.knobs.boolean(
    label: 'Show in Card',
    initialValue: false,
  );

  if (showMultiple) {
    final tags = [
      'Flutter',
      'Dart',
      'Mobile',
      'UI/UX',
      'Design System',
      'Storybook',
      'Android',
      'iOS',
    ];

    final tagWidgets = Wrap(
      spacing: context.space(factor: 0.5),
      runSpacing: context.space(factor: 0.5),
      children: tags.map((tag) => DSTagWidget(label: tag)).toList(),
    );

    if (inCard) {
      return Center(
        child: DSCardWidget(
          child: Padding(
            padding: EdgeInsets.all(context.space()),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  'Skills',
                  color: context.colorPalette.neutral.grey9,
                  style: context.typography.titleLarge,
                ),
                DSVerticalSpacerWidget(0.5),
                tagWidgets,
              ],
            ),
          ),
        ),
      );
    }

    return Center(child: tagWidgets);
  }

  return Center(child: DSTagWidget(label: label));
}
