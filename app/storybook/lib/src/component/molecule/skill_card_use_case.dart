import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Skill Card', type: DSSkillCardWidget)
Widget buildSkillCard(BuildContext context) {
  final name = context.knobs.string(label: 'Name', initialValue: 'Flutter');
  final description = context.knobs.string(
    label: 'Description',
    initialValue: 'Widgets and tooling for polished apps.',
  );
  final levelLabel = context.knobs.string(
    label: 'Level label',
    initialValue: 'Expert',
  );
  final progress = context.knobs.double.slider(
    label: 'Progress',
    initialValue: 0.75,
    max: 1,
  );
  final details = context.knobs.string(
    label: 'Details',
    initialValue: '6 yrs · Last used 2026',
  );
  final palette = context.colorPalette;
  final accent = context.knobs.object.dropdown<Color>(
    label: 'Accent',
    options: [
      palette.brand.primary.color,
      palette.brand.secondary.color,
      palette.brand.tertiary.color,
    ],
    initialOption: palette.brand.primary.color,
    labelBuilder: (color) => '#${color.toARGB32().toRadixString(16)}',
  );

  return Center(
    child: SizedBox(
      width: 320,
      child: DSSkillCardWidget(
        name: name,
        accent: accent,
        description: description.isEmpty ? null : description,
        levelLabel: levelLabel.isEmpty ? null : levelLabel,
        progress: progress,
        details: details.isEmpty ? null : details,
      ),
    ),
  );
}
