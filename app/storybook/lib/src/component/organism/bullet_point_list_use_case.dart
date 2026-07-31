import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Bullet Point List', type: DSBulletPointListWidget)
Widget buildBulletPointList(BuildContext context) {
  final bulletPointsText = context.knobs.string(
    label: 'Bullet Points (comma separated)',
    initialValue: 'Easy to use and integrate,Fully customizable design,Responsive layout support,Dark mode compatible,Accessibility features included',
  );
  
  final bulletPoints = bulletPointsText.split(',').map((e) => e.trim()).toList();
  
  final showInCard = context.knobs.boolean(label: 'Show in Card', initialValue: true);
  
  final showExamples = context.knobs.boolean(label: 'Show Examples', initialValue: false);
  
  if (showExamples) {
    final examples = [
      ('Features', [
        'Easy to use and integrate',
        'Fully customizable design',
        'Responsive layout support',
        'Dark mode compatible',
        'Accessibility features included',
      ]),
      ('Job Responsibilities', [
        'Design and develop high-quality Flutter applications',
        'Collaborate with cross-functional teams',
        'Write clean, maintainable, and efficient code',
        'Participate in code reviews and technical discussions',
        'Mentor junior developers',
      ]),
      ('Product Specs', [
        'Dimensions: 10" x 8" x 2"',
        'Weight: 2.5 lbs',
        'Material: Premium aluminum',
        'Color: Space Gray',
        'Battery Life: Up to 12 hours',
        'Connectivity: Wi-Fi 6, Bluetooth 5.0',
        'Warranty: 2 years',
      ]),
    ];
    
    final selectedExample = context.knobs.object.dropdown(
      label: 'Example Type',
      options: examples.map((e) => e.$2).toList(),
      labelBuilder: (points) => examples.firstWhere((e) => e.$2 == points).$1,
    );
    
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                examples.firstWhere((e) => e.$2 == selectedExample).$1,
                color: context.colorPalette.neutral.grey9,
                style: context.typography.titleLarge,
              ),
              DSVerticalSpacerWidget(1),
              DSBulletPointListWidget(bulletPoints: selectedExample),
            ],
          ),
        ),
      ),
    );
  }
  
  if (showInCard) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DSTextWidget(
                'Features',
                color: context.colorPalette.neutral.grey9,
                style: context.typography.titleLarge,
              ),
              DSVerticalSpacerWidget(1),
              DSBulletPointListWidget(bulletPoints: bulletPoints),
            ],
          ),
        ),
      ),
    );
  }
  
  return Center(
    child: DSBulletPointListWidget(bulletPoints: bulletPoints),
  );
}
