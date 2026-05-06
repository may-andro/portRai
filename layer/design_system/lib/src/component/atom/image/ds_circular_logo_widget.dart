import 'package:design_system/src/component/atom/image/ds_image.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

class DSCircularLogoWidget extends StatelessWidget {
  const DSCircularLogoWidget({super.key, this.size, this.backgroundColor});

  const DSCircularLogoWidget.white({super.key, this.size})
    : backgroundColor = Colors.white;

  const DSCircularLogoWidget.black({super.key, this.size})
    : backgroundColor = Colors.black;

  final double? size;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final containerSize = size ?? context.space(factor: 12);

    // Determine background color based on theme brightness if not explicitly set
    final effectiveBackgroundColor =
        backgroundColor ??
        (Theme.of(context).brightness == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Container(
      width: containerSize,
      height: containerSize,
      decoration: BoxDecoration(
        color: effectiveBackgroundColor,
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(containerSize * 0.15),
          // 15% padding for better visual appearance
          child: DSImage.logo(),
        ),
      ),
    );
  }
}
