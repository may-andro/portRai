import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';
import 'package:portrai/src/widget/page_band_widget.dart';
import 'package:portrai/src/widget/page_chrome_widget.dart';

/// Full-bleed hero: story on one side, the app icon on an animated stage on
/// the other.
class IntroWidget extends StatelessWidget {
  const IntroWidget({super.key, required this.project});

  final ProjectEntity project;

  static const _onHero = DSColor(0xFFFFFFFF);
  static const _onHeroMuted = DSColor(0xD9FFFFFF);

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    const base = Color(0xFF0E1726);
    final start = Color.lerp(base, palette.brand.primary.color, 0.3)!;
    final end = Color.lerp(base, palette.brand.tertiary.color, 0.25)!;
    return DSOffscreenPauseWidget(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 900;
          final stage = _StageWidget(project: project, isWide: isWide);
          final story = _StoryWidget(project: project, isWide: isWide);
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [start, end],
              ),
            ),
            child: ClipRect(
              child: Stack(
                children: [
                  _BlobWidget(
                    color: palette.brand.primary.color,
                    alignment: const Alignment(-1, -0.9),
                    driftX: 60,
                    driftY: 40,
                    seconds: 9,
                  ),
                  _BlobWidget(
                    color: palette.brand.tertiary.color,
                    alignment: const Alignment(1, 0.9),
                    driftX: -70,
                    driftY: -30,
                    seconds: 11,
                  ),
                  _BlobWidget(
                    color: palette.brand.secondary.color,
                    alignment: const Alignment(0.2, -1.2),
                    driftX: 50,
                    driftY: 50,
                    seconds: 13,
                  ),
                  const Positioned.fill(child: _GridWidget()),
                  PageChromeWidget(
                    closeColor: Colors.white,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: context.screenHorizontalPadding.left,
                        vertical: context.space(factor: isWide ? 8 : 4),
                      ),
                      child: isWide
                          ? Row(
                              spacing: context.space(factor: 6),
                              children: [
                                Expanded(flex: 6, child: story),
                                Expanded(flex: 4, child: stage),
                              ],
                            )
                          : Column(
                              spacing: context.space(factor: 4),
                              children: [stage, story],
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate().fadeIn(duration: 600.ms);
        },
      ),
    );
  }
}

class _BlobWidget extends StatelessWidget {
  const _BlobWidget({
    required this.color,
    required this.alignment,
    required this.driftX,
    required this.driftY,
    required this.seconds,
  });

  final Color color;
  final Alignment alignment;
  final double driftX;
  final double driftY;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    final size = context.space(factor: 36);
    return IgnorePointer(
      child: Align(
        alignment: alignment,
        child:
            Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [color.withAlpha(110), color.withAlpha(0)],
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .move(
                  begin: Offset.zero,
                  end: Offset(driftX, driftY),
                  duration: seconds.seconds,
                  curve: Curves.easeInOut,
                ),
      ),
    );
  }
}

/// Fine grid lines that fade out towards the bottom, like blueprint paper.
class _GridWidget extends StatelessWidget {
  const _GridWidget();

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ShaderMask(
        blendMode: BlendMode.dstIn,
        shaderCallback: (bounds) {
          return const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.transparent],
          ).createShader(bounds);
        },
        child: CustomPaint(painter: _GridPainter()),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(16)
      ..strokeWidth = 1;
    const gap = 56.0;
    for (var x = 0.0; x < size.width; x += gap) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += gap) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _StoryWidget extends StatelessWidget {
  const _StoryWidget({required this.project, required this.isWide});

  final ProjectEntity project;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            PageEyebrowWidget(project.category, onDark: true),
            DSTextWidget(
              project.title,
              style: isWide
                  ? context.typography.emphasizedDisplaySmall
                  : context.typography.emphasizedHeadlineLarge,
              color: IntroWidget._onHero,
              maxLines: 3,
            ),
            DSTextWidget(
              project.description,
              style: context.typography.bodyLarge,
              color: IntroWidget._onHeroMuted,
            ),
            _StatusPillWidget(status: project.status),
          ],
        )
        .animate(delay: 300.ms)
        .fadeIn(duration: 500.ms)
        .slideX(begin: 0.04, end: 0, duration: 500.ms);
  }
}

class _StatusPillWidget extends StatelessWidget {
  const _StatusPillWidget({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.space(factor: 1.5),
        vertical: context.space(factor: 0.75),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(100),
        color: Colors.white.withAlpha(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: context.space(factor: 0.75),
        children: [
          Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4ADE80),
                ),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .fade(begin: 0.4, end: 1, duration: 1.2.seconds),
          DSTextWidget(
            status.toUpperCase(),
            style: context.typography.emphasizedLabelMedium,
            color: IntroWidget._onHero,
          ),
        ],
      ),
    );
  }
}

/// The app icon on a tilted gradient plate, surrounded by slowly counter-
/// rotating dashed rings and two floating badges.
class _StageWidget extends StatelessWidget {
  const _StageWidget({required this.project, required this.isWide});

  final ProjectEntity project;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final stageSize = isWide ? 340.0 : 230.0;
    final plateSize = stageSize * 0.52;
    return Center(
      child: SizedBox(
        width: stageSize,
        height: stageSize,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _DashedRingWidget(size: stageSize, turns: 1, seconds: 50),
            _DashedRingWidget(size: stageSize * 0.76, turns: -1, seconds: 36),
            Transform.rotate(
                  angle: 0.16,
                  child: Container(
                    width: plateSize,
                    height: plateSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(plateSize * 0.225),
                      gradient: LinearGradient(
                        colors: [
                          palette.brand.primary.color,
                          palette.brand.tertiary.color,
                        ],
                      ),
                    ),
                  ),
                )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .scale(
                  begin: const Offset(1.08, 1.08),
                  end: const Offset(1.2, 1.2),
                  duration: 3.seconds,
                  curve: Curves.easeInOut,
                ),
            Hero(
                  tag: 'project-image-${project.id}',
                  child: Container(
                    width: plateSize,
                    height: plateSize,
                    padding: EdgeInsets.all(plateSize * 0.12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(plateSize * 0.225),
                      boxShadow: [
                        BoxShadow(
                          color: palette.brand.primary.color.withAlpha(120),
                          blurRadius: 50,
                          offset: const Offset(0, 20),
                        ),
                      ],
                    ),
                    child: DSNetworkImageWidget(
                      url: project.image,
                      fit: BoxFit.contain,
                    ),
                  ),
                )
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  duration: 800.ms,
                  delay: 200.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 300.ms, delay: 200.ms),
            const _FloatingBadgeWidget(
              alignment: Alignment(0.95, -0.55),
              icon: Icons.bolt_rounded,
              seconds: 3,
            ),
            const _FloatingBadgeWidget(
              alignment: Alignment(-0.95, 0.6),
              icon: Icons.auto_awesome_rounded,
              seconds: 4,
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatingBadgeWidget extends StatelessWidget {
  const _FloatingBadgeWidget({
    required this.alignment,
    required this.icon,
    required this.seconds,
  });

  final Alignment alignment;
  final IconData icon;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child:
          Container(
                padding: EdgeInsets.all(context.space(factor: 1.25)),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withAlpha(28),
                  border: Border.all(color: Colors.white30),
                ),
                child: Icon(icon, size: 20, color: Colors.white),
              )
              .animate(onPlay: (controller) => controller.repeat(reverse: true))
              .moveY(
                begin: -8,
                end: 8,
                duration: seconds.seconds,
                curve: Curves.easeInOut,
              ),
    );
  }
}

class _DashedRingWidget extends StatelessWidget {
  const _DashedRingWidget({
    required this.size,
    required this.turns,
    required this.seconds,
  });

  final double size;
  final double turns;
  final int seconds;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _DashedRingPainter())
        .animate(onPlay: (controller) => controller.repeat())
        .rotate(begin: 0, end: turns, duration: seconds.seconds);
  }
}

class _DashedRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(46)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;
    const dashCount = 48;
    const sweep = 2 * math.pi / dashCount;
    final rect = Offset.zero & size;
    for (var dashIndex = 0; dashIndex < dashCount; dashIndex++) {
      canvas.drawArc(rect, dashIndex * sweep, sweep * 0.5, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
