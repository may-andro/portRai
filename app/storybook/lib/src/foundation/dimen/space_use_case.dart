import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart';

@UseCase(name: 'DSSpace', type: DSSpace)
Widget build(BuildContext context) {
  final size = context.space(
    factor: context.knobs.object.dropdown(
      label: 'Factor',
      options: [1, 5, 10, 20, 30],
    ),
  );
  return Center(
    child: Card(
      color: context.colorPalette.brand.primary.color,
      child: SizedBox(height: size, width: size),
    ),
  );
}
