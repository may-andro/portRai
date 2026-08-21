import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'TextField', type: DSTextFieldWidget)
Widget buildTextField(BuildContext context) {
  final labelText = context.knobs.string(label: 'Label', initialValue: 'Label');

  final hintText = context.knobs.string(
    label: 'Hint',
    initialValue: 'Enter text here',
  );

  final helperText = context.knobs.stringOrNull(
    label: 'Helper Text',
    initialValue: null,
  );

  final fieldType = context.knobs.object.dropdown(
    label: 'Field Type',
    options: TextFieldType.values,
    labelBuilder: (value) => value.name,
  );

  final maxLines = context.knobs.int.slider(
    label: 'Max Lines',
    initialValue: 1,
    min: 1,
    max: 10,
  );

  final enabled = context.knobs.boolean(label: 'Enabled', initialValue: true);

  final readOnly = context.knobs.boolean(
    label: 'Read Only',
    initialValue: false,
  );

  final keyboardTypes = [
    ('Text', TextInputType.text),
    ('Email', TextInputType.emailAddress),
    ('Phone', TextInputType.phone),
    ('Number', TextInputType.number),
    ('Multiline', TextInputType.multiline),
  ];

  final selectedKeyboardType = context.knobs.object.dropdown(
    label: 'Keyboard Type',
    options: keyboardTypes.map((e) => e.$2).toList(),
    labelBuilder: (type) => keyboardTypes.firstWhere((e) => e.$2 == type).$1,
  );

  final hasSuffixIcon = context.knobs.boolean(
    label: 'Has Suffix Icon',
    initialValue: false,
  );

  return Center(
    child: DSTextFieldWidget(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      textFieldType: fieldType,
      maxLines: maxLines,
      enabled: enabled,
      readOnly: readOnly,
      keyboardType: selectedKeyboardType,
      suffixIcon: hasSuffixIcon ? Icons.search : null,
    ),
  );
}
