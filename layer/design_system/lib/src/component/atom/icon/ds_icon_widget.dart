import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/color/color.dart';
import 'package:flutter/material.dart';

enum DSIconSize { small, medium, large }

class DSIconWidget extends StatelessWidget {
  const DSIconWidget(
    this.icon, {
    super.key,
    required this.color,
    required this.size,
  });

  final IconData icon;
  final DSColor color;
  final DSIconSize size;

  static double getHeight(BuildContext context, DSIconSize size) {
    return size.getSize(context);
  }

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size.getSize(context), color: color.color);
  }
}

extension DSIconSizeExtension on DSIconSize {
  double getSize(BuildContext context) {
    switch (this) {
      case DSIconSize.small:
        return context.space(factor: context.isDesktop ? 1.5 : 2);
      case DSIconSize.medium:
        return context.space(factor: context.isDesktop ? 2 : 2.5);
      case DSIconSize.large:
        return context.space(factor: context.isDesktop ? 2.5 : 3);
    }
  }
}
