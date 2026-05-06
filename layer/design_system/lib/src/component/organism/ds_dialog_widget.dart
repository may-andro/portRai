import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:flutter/material.dart';

class DSDialogWidget extends StatelessWidget {
  const DSDialogWidget({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
      ),
      backgroundColor: context.colorPalette.background.color,
      clipBehavior: Clip.antiAlias,
      elevation: context.dimen.elevationLevel3.value,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.isDesktop ? 400 : context.screenWidth * 0.9,
          maxHeight: context.screenHeight * 0.8,
          minWidth: context.isDesktop ? 300 : context.screenWidth * 0.8,
        ),
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: child,
        ),
      ),
    );
  }
}
