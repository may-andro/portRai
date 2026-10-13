import 'package:flutter/material.dart';

/// A portrait frame shaped like an arched window. The [child] (ideally a
/// transparent cut-out photo) is anchored to the flat bottom edge and is
/// scaled so the subject's shoulders meet the frame edges so its head rises above the arch, giving a "pop-out"
/// effect while the body stays grounded inside the frame.
class DSArchPortraitWidget extends StatelessWidget {
  const DSArchPortraitWidget({
    super.key,
    required this.height,
    required this.child,
    required this.gradientColors,
    required this.outlineColor,
  });

  final double height;

  /// Rendered at the frame width and sized by its own aspect ratio, e.g.
  /// `DSNetworkImageWidget(fit: BoxFit.fitWidth, autoSizeImage: true)`.
  final Widget child;

  final List<Color> gradientColors;

  final Color outlineColor;

  @override
  Widget build(BuildContext context) {
    final width = height * 0.78;
    final archTop = height * 0.3;
    final topRadius = Radius.circular(width / 2);

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            top: archTop - 14,
            left: -14,
            right: -14,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: topRadius,
                  topRight: topRadius,
                ),
                border: Border.all(color: outlineColor, width: 2),
              ),
            ),
          ),
          Positioned(
            top: archTop,
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: topRadius,
                  topRight: topRadius,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: gradientColors,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRect(
              child: OverflowBox(
                minWidth: 0,
                minHeight: 0,
                maxWidth: width * 1.2,
                alignment: Alignment.bottomCenter,
                child: SizedBox(width: width * 1.2, child: child),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
