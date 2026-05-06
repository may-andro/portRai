import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A small rounded badge used to display skill/technology/category labels.
/// Uses the brand primary container colour scheme.
class DSTagWidget extends StatelessWidget {
  const DSTagWidget({super.key, required this.label});

  final String label;

  /// Returns the rendered height of a single tag (vertical padding + label text).
  static double getHeight(BuildContext context) {
    return context.space(factor: 0.25) +
        context.getTextHeight(context.typography.labelSmall, 1) +
        context.space(factor: 0.25);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 0.5),
        vertical: context.space(factor: 0.25),
      ),
      decoration: BoxDecoration(
        color: context.colorPalette.brand.primaryContainer.color,
        borderRadius: BorderRadius.circular(
          context.dimen.elevationLevel3.value,
        ),
      ),
      child: DSTextWidget(
        label,
        color: context.colorPalette.brand.onPrimaryContainer,
        style: context.typography.labelSmall,
      ),
    );
  }
}
