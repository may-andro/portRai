import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'DSElevation', type: DSElevation)
Widget build(BuildContext context) {
  final elevationMap = <double, String>{
    context.dimen.elevationLevel1.value: 'Level1',
    context.dimen.elevationLevel2.value: 'Level2',
    context.dimen.elevationLevel3.value: 'Level3',
    context.dimen.elevationNone.value: 'None',
  };
  final elevation = context.knobs.object.dropdown<double>(
    label: 'Elevation Type',
    options: elevationMap.keys.toList(),
    labelBuilder: (option) => elevationMap[option] ?? 'Not found',
  );
  return Center(
    child: Card(
      elevation: elevation,
      color: context.colorPalette.brand.primary.color,
      child: const SizedBox(height: 120, width: 120),
    ),
  );
}
