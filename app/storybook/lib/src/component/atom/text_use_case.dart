import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';
import '../../extensions/extensions.dart';

@UseCase(name: 'Text Widget', type: DSTextWidget)
Widget buildTextWidget(BuildContext context) {
  final styleMap = context.typographyStylesMap;
  final selectedStyleName = context.knobs.object.dropdown(
    label: 'Style',
    options: styleMap.keys.toList(),
    labelBuilder: (name) => name,
  );
  
  final selectedStyle = styleMap[selectedStyleName]!;
  
  final text = context.knobs.string(
    label: 'Text',
    initialValue: 'The quick brown fox jumps over the lazy dog',
  );
  
  final isItalic = context.knobs.boolean(label: 'Italic', initialValue: false);
  
  final decoration = context.knobs.object.dropdown(
    label: 'Decoration',
    options: [
      TextDecoration.none,
      TextDecoration.underline,
      TextDecoration.lineThrough,
    ],
    labelBuilder: (value) => value.toString().split('.').last,
  );
  
  final alignment = context.knobs.object.dropdown(
    label: 'Text Align',
    options: [TextAlign.left, TextAlign.center, TextAlign.right],
    labelBuilder: (value) => value.toString().split('.').last,
  );
  
  final maxLines = context.knobs.int.slider(
    label: 'Max Lines',
    initialValue: 3,
    min: 1,
    max: 10,
  );
  
  return Center(
    child: DSTextWidget(
      text,
      color: context.colorPalette.neutral.grey9,
      style: selectedStyle,
      isItalic: isItalic,
      decoration: decoration,
      textAlign: alignment,
      maxLines: maxLines,
      textOverflow: TextOverflow.ellipsis,
    ),
  );
}
