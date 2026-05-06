import 'package:design_system/src/component/atom/atom.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

/// A simple titled section used inside scrollable detail screens (e.g.
/// experience or project detail). Renders a bold [titleLarge] heading above
/// [child] content separated by [space(1.5)], with [space(4)] bottom padding.
class DSDetailSectionWidget extends StatelessWidget {
  const DSDetailSectionWidget({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: context.space(factor: 4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          DSTextWidget(
            title,
            style: context.typography.titleLarge,
            color: context.colorPalette.neutral.grey9,
          ),
          child,
        ],
      ),
    );
  }
}
