import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Expandable Card', type: DSExpandableCardWidget)
Widget buildExpandableCard(BuildContext context) {
  final headerText = context.knobs.string(
    label: 'Header',
    initialValue: 'Click to expand',
  );

  final contentText = context.knobs.string(
    label: 'Content',
    initialValue:
        'This is the expanded content that appears when you click the header.',
  );

  final showFaqList = context.knobs.boolean(
    label: 'Show FAQ List',
    initialValue: false,
  );

  if (showFaqList) {
    final faqs = [
      {
        'question': 'What is Flutter?',
        'answer':
            'Flutter is Google\'s UI toolkit for building beautiful, natively compiled applications for mobile, web, and desktop from a single codebase.',
      },
      {
        'question': 'What is a Design System?',
        'answer':
            'A design system is a collection of reusable components, guided by clear standards, that can be assembled together to build any number of applications.',
      },
      {
        'question': 'What is Storybook?',
        'answer':
            'Storybook is a frontend workshop for building UI components and pages in isolation. It helps you develop and share hard-to-reach states and edge cases.',
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.all(context.space()),
      itemCount: faqs.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: context.space()),
          child: DSExpandableCardWidget(
            headerContent: DSTextWidget(
              faqs[index]['question']!,
              color: context.colorPalette.neutral.grey9,
              style: context.typography.titleMedium,
            ),
            expandedContent: Padding(
              padding: EdgeInsets.all(context.space()),
              child: DSTextWidget(
                faqs[index]['answer']!,
                color: context.colorPalette.neutral.grey7,
                style: context.typography.bodyMedium,
              ),
            ),
          ),
        );
      },
    );
  }

  return Center(
    child: DSExpandableCardWidget(
      headerContent: DSTextWidget(
        headerText,
        color: context.colorPalette.neutral.grey9,
        style: context.typography.titleMedium,
      ),
      expandedContent: Padding(
        padding: EdgeInsets.all(context.space()),
        child: DSTextWidget(
          contentText,
          color: context.colorPalette.neutral.grey7,
          style: context.typography.bodyMedium,
        ),
      ),
    ),
  );
}
