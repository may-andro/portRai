import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'DSRadius', type: DSRadius)
Widget build(BuildContext context) {
  final radiusMap = <double, String>{
    context.dimen.radiusLevel1.value: 'Level 1',
    context.dimen.radiusLevel2.value: 'Level 2',
    context.dimen.radiusLevel3.value: 'Level 3',
    context.dimen.radiusCircular.value: 'Circular',
  };

  final radius = context.knobs.object.dropdown<double>(
    label: 'Radius Type',
    options: radiusMap.keys.toList(),
    labelBuilder: (option) => radiusMap[option] ?? 'Not found',
  );
  return Center(
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(radius)),
      ),
      color: context.colorPalette.brand.primary.color,
      child: const SizedBox(height: 120, width: 120),
    ),
  );
}
