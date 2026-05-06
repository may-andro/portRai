import 'package:design_system/src/component/atom/loading/ds_loading_widget.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

class DSIconButtonWidget extends StatelessWidget {
  const DSIconButtonWidget(
    this.icon, {
    required this.iconColor,
    required this.buttonColor,
    this.size = DSIconButtonSize.small,
    this.isLoading = false,
    this.onPressed,
    this.elevation,
    super.key,
  });

  final IconData icon;
  final DSColor iconColor;
  final DSColor buttonColor;
  final DSIconButtonSize size;
  final bool isLoading;
  final VoidCallback? onPressed;
  final DSElevation? elevation;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(
          context.space(factor: size.heightFactor),
          context.space(factor: size.heightFactor),
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        minimumSize: Size.zero,
        shadowColor: context.colorPalette.neutral.transparent.color,
        backgroundColor: buttonColor.color,
        shape: const CircleBorder(),
        padding: EdgeInsets.zero,
        elevation: elevation?.value ?? context.dimen.elevationNone.value,
      ),
      child: isLoading
          ? DSLoadingWidget(size: context.space(factor: size.iconSizeFactor))
          : Icon(
              icon,
              size: context.space(factor: size.iconSizeFactor),
              color: onPressed != null
                  ? iconColor.color
                  : context.colorPalette.disabled.color,
            ),
    );
  }
}

enum DSIconButtonSize {
  small(4, 2.5),
  medium(5, 2.8),
  large(6, 3);

  const DSIconButtonSize(this.heightFactor, this.iconSizeFactor);

  final double heightFactor;
  final double iconSizeFactor;
}
