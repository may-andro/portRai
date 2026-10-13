import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(
  name: 'Floating Shapes Background',
  type: DSFloatingShapesBackgroundWidget,
)
Widget buildFloatingShapesBackground(BuildContext context) {
  final shapeCount = context.knobs.int.slider(
    label: 'Shape count',
    initialValue: 16,
    min: 1,
    max: 40,
  );
  final seconds = context.knobs.int.slider(
    label: 'Loop duration (s)',
    initialValue: 24,
    min: 4,
    max: 60,
  );

  return DSFloatingShapesBackgroundWidget(
    color: context.colorPalette.brand.primary.color,
    shapeCount: shapeCount,
    duration: Duration(seconds: seconds),
  );
}
