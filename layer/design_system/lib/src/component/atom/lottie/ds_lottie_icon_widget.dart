import 'package:design_system/assets/assets.gen.dart';
import 'package:design_system/src/component/atom/lottie/ds_lottie_widget.dart';
import 'package:design_system/src/foundation/foundation.dart';
import 'package:flutter/material.dart';

/// Single-color animated icons. To add one, drop a line-art Lottie file in
/// `assets/lottie/`, regenerate the assets and add a value here.
enum DSLottieIcon {
  folder(Icons.folder_special_outlined),
  language(Icons.translate_rounded),
  paperPlane(Icons.send_rounded),
  medal(Icons.workspace_premium_rounded);

  const DSLottieIcon(this.fallbackIcon);

  final IconData fallbackIcon;

  LottieGenImage get asset {
    switch (this) {
      case DSLottieIcon.folder:
        return Assets.lottie.folder;
      case DSLottieIcon.language:
        return Assets.lottie.language;
      case DSLottieIcon.paperPlane:
        return Assets.lottie.paperPlane;
      case DSLottieIcon.medal:
        return Assets.lottie.medal;
    }
  }
}

/// An animated icon fully recolored to [color].
class DSLottieIconWidget extends StatelessWidget {
  const DSLottieIconWidget({
    super.key,
    required this.icon,
    required this.size,
    required this.color,
    this.playback = DSLottiePlayback.once,
    this.trigger = 0,
  });

  final DSLottieIcon icon;
  final double size;
  final Color color;
  final DSLottiePlayback playback;

  /// Replays the animation when it changes, see [DSLottiePlayback.trigger].
  final int trigger;

  @override
  Widget build(BuildContext context) {
    return DSLottieWidget(
      asset: icon.asset,
      size: size,
      playback: playback,
      trigger: trigger,
      colorOverrides: [
        DSLottieColorOverride(
          keyPath: const ['**'],
          color: DSColor(color.toARGB32()),
        ),
      ],
      fallback: Icon(icon.fallbackIcon, size: size, color: color),
    );
  }
}
