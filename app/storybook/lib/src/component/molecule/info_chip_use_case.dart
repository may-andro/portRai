import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Info Chip', type: DSInfoChipWidget)
Widget buildInfoChip(BuildContext context) {
  final icons = [
    Icons.calendar_today,
    Icons.location_on,
    Icons.person,
    Icons.work,
    Icons.access_time,
    Icons.email,
    Icons.phone,
    Icons.event,
  ];

  final selectedIcon = context.knobs.object.dropdown(
    label: 'Icon',
    options: icons,
    labelBuilder: (icon) => icon.toString().split('.').last,
  );

  final label = context.knobs.string(label: 'Label', initialValue: 'Jan 2024');

  final showMultiple = context.knobs.boolean(
    label: 'Show Multiple',
    initialValue: false,
  );

  final inCard = context.knobs.boolean(
    label: 'Show in Card',
    initialValue: false,
  );

  if (showMultiple) {
    final chips = Wrap(
      spacing: context.space(factor: 0.5),
      runSpacing: context.space(factor: 0.5),
      children: [
        DSInfoChipWidget(
          icon: Icons.calendar_today,
          label: 'December 25, 2024',
        ),
        DSInfoChipWidget(icon: Icons.location_on, label: 'San Francisco, CA'),
        DSInfoChipWidget(icon: Icons.access_time, label: '10:00 AM - 5:00 PM'),
        DSInfoChipWidget(icon: Icons.people, label: '500+ Attendees'),
      ],
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
                  'Event Details',
                  color: context.colorPalette.neutral.grey9,
                  style: context.typography.titleLarge,
                ),
                DSVerticalSpacerWidget(1),
                chips,
              ],
            ),
          ),
        ),
      );
    }

    return Center(child: chips);
  }

  return Center(
    child: DSInfoChipWidget(icon: selectedIcon, label: label),
  );
}
