part of '../professional_summary_widget.dart';

/// Faint dot grid that fades towards the edges, for engineering backgrounds.
class _BlueprintGridWidget extends StatelessWidget {
  const _BlueprintGridWidget({required this.isVisible});

  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final color = context.colorPalette.brand.primary.color;

    return IgnorePointer(
      child: RepaintBoundary(
        child: ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (bounds) => const RadialGradient(
            center: Alignment.centerRight,
            radius: 1.1,
            colors: [Colors.white, Colors.transparent],
          ).createShader(bounds),
          child: CustomPaint(
            painter: _DotGridPainter(color: color.withAlpha(70)),
            size: Size.infinite,
          ),
        ).animate(target: isVisible ? 1 : 0).fadeIn(duration: 600.ms),
      ),
    );
  }
}

class _DotGridPainter extends CustomPainter {
  const _DotGridPainter({required this.color});

  final Color color;

  static const _spacing = 28.0;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (var dx = _spacing / 2; dx < size.width; dx += _spacing) {
      for (var dy = _spacing / 2; dy < size.height; dy += _spacing) {
        canvas.drawCircle(Offset(dx, dy), 1.2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotGridPainter oldDelegate) => color != oldDelegate.color;
}
