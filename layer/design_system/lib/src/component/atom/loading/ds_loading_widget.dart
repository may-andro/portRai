import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';

enum DSLoadingStyle { dots, lottie }

class DSLoadingWidget extends StatelessWidget {
  const DSLoadingWidget({
    super.key,
    required this.size,
    this.color,
    this.style = DSLoadingStyle.dots,
  });

  final double size;
  final DSColor? color;
  final DSLoadingStyle style;

  @override
  Widget build(BuildContext context) {
    final resolvedColor =
        color?.color ?? context.theme.colorPalette.brand.primary.color;
    final dots = LoadingAnimationWidget.staggeredDotsWave(
      color: resolvedColor,
      size: size,
    );

    return Center(
      child: switch (style) {
        DSLoadingStyle.dots => dots,
        DSLoadingStyle.lottie => Assets.lottie.loader.lottie(
          package: 'design_system',
          width: size * 2,
          height: size * 2,
          // Recolors every fill and stroke, so any single-color loader works.
          delegates: LottieDelegates(
            values: [
              ValueDelegate.color(const ['**'], value: resolvedColor),
            ],
          ),
          errorBuilder: (_, _, _) => dots,
        ),
      },
    );
  }
}
