import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Quote Text', type: DSQuoteTextWidget)
Widget buildQuoteText(BuildContext context) {
  final text = context.knobs.string(
    label: 'Quote Text',
    initialValue: 'The only way to do great work is to love what you do.',
  );
  
  final maxLines = context.knobs.int.slider(
    label: 'Max Lines',
    initialValue: 2,
    min: 1,
    max: 10,
  );
  
  final inProfile = context.knobs.boolean(label: 'Show in Profile Card', initialValue: false);
  
  if (inProfile) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: context.colorPalette.brand.primary.color,
                    child: DSTextWidget(
                      'JD',
                      color: context.colorPalette.brand.onPrimary,
                      style: context.typography.headlineSmall,
                    ),
                  ),
                  DSHorizontalSpacerWidget(1),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DSTextWidget(
                        'John Doe',
                        color: context.colorPalette.neutral.grey9,
                        style: context.typography.titleLarge,
                      ),
                      DSTextWidget(
                        'CEO & Founder',
                        color: context.colorPalette.neutral.grey7,
                        style: context.typography.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
              DSVerticalSpacerWidget(1),
              DSHorizontalDividerWidget(
                thickness: 1,
                color: context.colorPalette.outline.outlineVariant,
              ),
              DSVerticalSpacerWidget(1),
              DSQuoteTextWidget(
                text: text,
                maxLines: maxLines,
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
        child: DSQuoteTextWidget(
          text: text,
          maxLines: maxLines,
        ),
      ),
    ),
  );
}
