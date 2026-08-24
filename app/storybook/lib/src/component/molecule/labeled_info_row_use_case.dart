import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Labeled Info Row', type: DSLabeledInfoRowWidget)
Widget buildLabeledInfoRow(BuildContext context) {
  final icons = [
    Icons.email,
    Icons.phone,
    Icons.location_on,
    Icons.work,
    Icons.settings,
    Icons.notifications,
    Icons.security,
  ];

  final selectedIcon = context.knobs.object.dropdown(
    label: 'Icon',
    options: icons,
    labelBuilder: (icon) => icon.toString().split('.').last,
  );

  final label = context.knobs.string(label: 'Label', initialValue: 'Email');

  final value = context.knobs.string(
    label: 'Value',
    initialValue: 'john.doe@example.com',
  );

  final isClickable = context.knobs.boolean(
    label: 'Clickable',
    initialValue: false,
  );

  final showMultiple = context.knobs.boolean(
    label: 'Show Multiple in Card',
    initialValue: false,
  );

  if (showMultiple) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            children: [
              DSLabeledInfoRowWidget(
                icon: Icons.settings,
                label: 'Settings',
                value: 'Manage your account',
                onTap: isClickable ? () {} : null,
              ),
              DSVerticalSpacerWidget(1),
              DSHorizontalDividerWidget(
                thickness: 1,
                color: context.colorPalette.outline.outlineVariant,
              ),
              DSVerticalSpacerWidget(1),
              DSLabeledInfoRowWidget(
                icon: Icons.notifications,
                label: 'Notifications',
                value: 'Push, Email, SMS',
                onTap: isClickable ? () {} : null,
              ),
              DSVerticalSpacerWidget(1),
              DSHorizontalDividerWidget(
                thickness: 1,
                color: context.colorPalette.outline.outlineVariant,
              ),
              DSVerticalSpacerWidget(1),
              DSLabeledInfoRowWidget(
                icon: Icons.security,
                label: 'Privacy',
                value: 'Manage privacy settings',
                onTap: isClickable ? () {} : null,
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Center(
    child: DSLabeledInfoRowWidget(
      icon: selectedIcon,
      label: label,
      value: value,
      onTap: isClickable ? () {} : null,
    ),
  );
}
