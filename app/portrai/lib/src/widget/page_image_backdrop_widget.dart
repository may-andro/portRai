import 'package:flutter/material.dart';

/// Photo backdrop for a band, washed with [washColor] so content stays legible
/// in light and dark themes. The placement parameters let each page frame the
/// same image differently.
class PageImageBackdropWidget extends StatelessWidget {
  const PageImageBackdropWidget({
    super.key,
    required this.asset,
    required this.washColor,
    this.imageAlignment = Alignment.center,
    this.isFlipped = false,
    this.washBegin = Alignment.centerLeft,
    this.washEnd = Alignment.centerRight,
    this.washOpacityAtBegin = 1,
    this.washOpacityAtEnd = 0.8,
  });

  final String asset;
  final Color washColor;
  final Alignment imageAlignment;
  final bool isFlipped;
  final Alignment washBegin;
  final Alignment washEnd;
  final double washOpacityAtBegin;
  final double washOpacityAtEnd;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      asset,
      fit: BoxFit.cover,
      alignment: imageAlignment,
    );
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (isFlipped) Transform.flip(flipX: true, child: image) else image,
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: washBegin,
                end: washEnd,
                colors: [
                  washColor.withValues(alpha: washOpacityAtBegin),
                  washColor.withValues(alpha: washOpacityAtEnd),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
