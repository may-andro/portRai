import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Tab Item', type: DSTabItemWidget)
Widget buildTabItem(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Home');

  final isSelected = context.knobs.boolean(
    label: 'Selected',
    initialValue: false,
  );

  final isIndicatorEnabled = context.knobs.boolean(
    label: 'Show Indicator',
    initialValue: true,
  );

  final showTabBar = context.knobs.boolean(
    label: 'Show Complete Tab Bar',
    initialValue: false,
  );

  if (showTabBar) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  DSTabItemWidget(
                    title: 'Overview',
                    onTap: () {},
                    isSelected: true,
                    isIndicatorEnabled: true,
                  ),
                  DSTabItemWidget(
                    title: 'Projects',
                    onTap: () {},
                    isSelected: false,
                    isIndicatorEnabled: true,
                  ),
                  DSTabItemWidget(
                    title: 'Team',
                    onTap: () {},
                    isSelected: false,
                    isIndicatorEnabled: true,
                  ),
                  DSTabItemWidget(
                    title: 'Settings',
                    onTap: () {},
                    isSelected: false,
                    isIndicatorEnabled: true,
                  ),
                ],
              ),
              DSVerticalSpacerWidget(1),
              DSTextWidget(
                'Tab content goes here...',
                color: context.colorPalette.neutral.grey7,
                style: context.typography.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }

  return Center(
    child: DSTabItemWidget(
      title: title,
      onTap: () {},
      isSelected: isSelected,
      isIndicatorEnabled: isIndicatorEnabled,
    ),
  );
}
