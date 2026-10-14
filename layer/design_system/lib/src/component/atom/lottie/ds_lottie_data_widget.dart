import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Plays a Lottie animation generated at runtime, given as JSON bytes. It
/// loops and keeps the animation's own colors.
class DSLottieDataWidget extends StatelessWidget {
  const DSLottieDataWidget({
    super.key,
    required this.data,
    this.aspectRatio = 800 / 300,
    this.fit = BoxFit.contain,
  });

  final Uint8List data;
  final double aspectRatio;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Lottie.memory(data, fit: fit),
    );
  }
}
