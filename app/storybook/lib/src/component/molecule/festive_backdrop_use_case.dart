import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'Festive Backdrop', type: DSFestiveBackdropWidget)
Widget buildFestiveBackdrop(BuildContext context) {
  final seconds = context.knobs.int.slider(
    label: 'Loop duration (s)',
    initialValue: 12,
    min: 2,
    max: 30,
  );
  final particleCount = context.knobs.int.slider(
    label: 'Particle count',
    initialValue: 28,
    min: 4,
    max: 80,
  );

  final effectOpacity = context.knobs.double.slider(
    label: 'Effect opacity',
    initialValue: 0.35,
    min: 0,
    max: 1,
  );
  final shape = context.knobs.object.dropdown(
    label: 'Shape',
    options: DSFestiveBackdropShape.values,
    initialOption: DSFestiveBackdropShape.rectangle,
    labelBuilder: (value) => value.name,
  );

  return ColoredBox(
    color: context.colorPalette.surface.inverseSurface.color,
    child: SizedBox.expand(
      child: DSFestiveBackdropWidget(
        shape: shape,
        effectOpacity: effectOpacity,
        duration: Duration(seconds: seconds),
        particleCount: particleCount,
      ),
    ),
  );
}
