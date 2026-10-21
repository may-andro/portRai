import 'dart:math';

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/l10n/l10n.dart';

/// How strongly a score suggests applying. The tiers match the scoring
/// prompt: 80 and up means the core stack is covered.
enum JobFitTier {
  strong,
  good,
  possible;

  factory JobFitTier.of(int score) => switch (score) {
    >= 80 => JobFitTier.strong,
    >= 70 => JobFitTier.good,
    _ => JobFitTier.possible,
  };

  DSColor color(BuildContext context) => switch (this) {
    JobFitTier.strong => context.colorPalette.semantic.success,
    JobFitTier.good => context.colorPalette.accent,
    JobFitTier.possible => context.colorPalette.semantic.warning,
  };

  String label(BuildContext context) => switch (this) {
    JobFitTier.strong => context.localizations.jobOpeningFitStrong,
    JobFitTier.good => context.localizations.jobOpeningFitGood,
    JobFitTier.possible => context.localizations.jobOpeningFitPossible,
  };
}

/// A ring that fills to [score] percent, with the score in the middle.
class JobFitScoreWidget extends StatelessWidget {
  const JobFitScoreWidget({super.key, required this.score, this.size = 56});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = JobFitTier.of(score).color(context).color;
    final trackColor = color.withAlpha(40);
    final isLarge = size >= 120;

    return Semantics(
      label: context.localizations.jobOpeningScore(score),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: score / 100),
        duration: const Duration(milliseconds: 900),
        curve: Curves.easeOutCubic,
        builder: (context, progress, _) {
          return SizedBox.square(
            dimension: size,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                color: color,
                trackColor: trackColor,
                strokeWidth: max(4, size * 0.08),
              ),
              child: Center(
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DSTextWidget(
                        '${(progress * 100).round()}',
                        style: isLarge
                            ? context.typography.emphasizedDisplaySmall
                            : context.typography.emphasizedTitleMedium,
                        color: context.colorPalette.neutral.grey10,
                      ),
                      if (isLarge)
                        DSTextWidget(
                          context.localizations.jobOpeningFitLabel,
                          style: context.typography.labelLarge,
                          color: context.colorPalette.neutral.grey7,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final bounds = Offset.zero & size;
    final ring = bounds.deflate(strokeWidth / 2);
    final track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    final arc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas
      ..drawArc(ring, 0, 2 * pi, false, track)
      ..drawArc(ring, -pi / 2, 2 * pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.strokeWidth != strokeWidth;
}
