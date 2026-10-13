import 'dart:math';

import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:flutter/material.dart';

class DSDialogWidget extends StatelessWidget {
  const DSDialogWidget({super.key, required this.child, this.maxWidth});

  final Widget child;

  /// Overrides the default desktop max width (400).
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    final double resolvedMaxWidth =
        maxWidth ?? (context.isDesktop ? 400 : context.screenWidth * 0.9);
    final double defaultMinWidth = context.isDesktop
        ? 300
        : context.screenWidth * 0.8;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
      ),
      backgroundColor: context.colorPalette.background.color,
      clipBehavior: Clip.antiAlias,
      elevation: context.dimen.elevationLevel3.value,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: resolvedMaxWidth,
          maxHeight: context.screenHeight * 0.8,
          minWidth: min(defaultMinWidth, resolvedMaxWidth),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: child,
        ),
      ),
    );
  }
}
