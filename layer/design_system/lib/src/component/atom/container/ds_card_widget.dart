import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/extension/ds_color_roles_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

class DSCardWidget extends StatelessWidget {
  const DSCardWidget({
    super.key,
    required this.child,
    this.backgroundColor,
    this.splashColor,
    this.shadowColor,
    this.surfaceTintColor,
    this.radius,
    this.elevation,
    this.onTap,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
    this.backgroundColorOpacity = 1.0,
  });

  final Widget child;
  final DSColor? backgroundColor;
  final DSColor? shadowColor;
  final DSColor? splashColor;
  final DSColor? surfaceTintColor;
  final DSRadius? radius;
  final DSElevation? elevation;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;
  final double backgroundColorOpacity;

  BorderRadius get _borderRadius => BorderRadius.circular(radius?.value ?? 12);

  ShapeBorder get _shape => RoundedRectangleBorder(borderRadius: _borderRadius);

  @override
  Widget build(BuildContext context) {
    final card = Card(
      color:
          backgroundColor?.color.withValues(alpha: backgroundColorOpacity) ??
          context.colorPalette.background.color.withValues(
            alpha: backgroundColorOpacity,
          ),
      shadowColor: shadowColor?.color,
      surfaceTintColor: surfaceTintColor?.color,
      clipBehavior: clipBehavior,
      elevation: elevation?.value ?? 1,
      shape: _shape,
      margin: margin ?? EdgeInsets.zero,
      child: onTap != null
          ? InkWell(
              splashColor: splashColor?.color,
              onTap: onTap,
              customBorder: _shape,
              child: child,
            )
          : child,
    );
    return card;
  }
}
