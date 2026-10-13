import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Availability Badge', type: DSAvailabilityBadgeWidget)
Widget buildAvailabilityBadge(BuildContext context) {
  final label = context.knobs.string(
    label: 'Label',
    initialValue: 'Available for work · Full-time',
  );

  return Center(
    child: DSAvailabilityBadgeWidget(
      label: label,
      color: const Color(0xFF22C55E),
      textColor: context.colorPalette.neutral.grey9,
    ),
  );
}
