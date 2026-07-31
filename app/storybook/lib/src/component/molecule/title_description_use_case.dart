import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Title Description', type: DSTitleDescriptionWidget)
Widget buildTitleDescription(BuildContext context) {
  final title = context.knobs.string(label: 'Title', initialValue: 'Product Title');
  
  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'This is a detailed description of the product that provides more information.',
  );
  
  final titleMaxLines = context.knobs.int.slider(
    label: 'Title Max Lines',
    initialValue: 2,
    min: 1,
    max: 5,
  );
  
  final descriptionMaxLines = context.knobs.int.slider(
    label: 'Description Max Lines',
    initialValue: 3,
    min: 1,
    max: 10,
  );
  
  final isCentered = context.knobs.boolean(label: 'Centered', initialValue: false);
  
  final inCard = context.knobs.boolean(label: 'Show in Card', initialValue: true);
  
  final widget = DSTitleDescriptionWidget(
    title: title,
    description: description,
    titleMaxLines: titleMaxLines,
    descriptionMaxLines: descriptionMaxLines,
    isCenteredContent: isCentered,
  );
  
  if (inCard) {
    return Center(
      child: DSCardWidget(
        child: Padding(
          padding: EdgeInsets.all(context.space()),
          child: widget,
        ),
      ),
    );
  }
  
  return Center(child: widget);
}
