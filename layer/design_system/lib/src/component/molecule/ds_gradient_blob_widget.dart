import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// A decorative animated blob: a rounded [RadialGradient] container that
/// continuously pulses between [scaleBegin] and [scaleEnd].
///
/// Typically positioned absolutely in a [Stack] as a background accent.
class DSGradientBlobWidget extends StatelessWidget {
  const DSGradientBlobWidget({
    super.key,
    required this.size,
    required this.colors,
    required this.scaleBegin,
    required this.scaleEnd,
    required this.duration,
  });

  /// Diameter of the blob in logical pixels.
  final double size;

  /// Two colours for the [RadialGradient] (inner → outer).
  final List<Color> colors;

  /// Starting scale for the pulse animation.
  final Offset scaleBegin;

  /// Ending scale for the pulse animation.
  final Offset scaleEnd;

  /// Duration of one pulse cycle (animation auto-repeats in reverse).
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: RadialGradient(colors: colors, radius: 0.8),
            borderRadius: BorderRadius.circular(size * 0.8),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: scaleBegin,
          end: scaleEnd,
          duration: duration,
          curve: Curves.easeInOut,
        );
  }
}
