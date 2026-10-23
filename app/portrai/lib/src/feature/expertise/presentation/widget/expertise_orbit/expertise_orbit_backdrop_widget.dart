part of 'expertise_orbit_widget.dart';

/// Background detail for the section that holds [ExpertiseOrbitWidget]: drifting
/// shapes and, at the bottom right, the selected expertise's bar chart faded
/// out. Fill the whole section with it so it can reach the edges.
class ExpertiseOrbitBackdropWidget extends StatelessWidget {
  const ExpertiseOrbitBackdropWidget({
    super.key,
    required this.expertises,
    required this.selection,
    required this.isVisible,
  });

  final List<ExpertiseEntity> expertises;
  final ValueListenable<int> selection;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    if (expertises.isEmpty) return const SizedBox.shrink();

    return DSOffscreenPauseWidget(
      child: IgnorePointer(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Positioned.fill(
                  child: _OrbitBackdropWidget(
                    color: context.colorPalette.brand.primary.color,
                    isVisible: isVisible,
                  ),
                ),
                // Too small to read on mobile.
                if (!context.isMobile)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: ValueListenableBuilder<int>(
                      valueListenable: selection,
                      builder: (context, index, _) => _OrbitStatsChartWidget(
                        expertise:
                            expertises[min(index, expertises.length - 1)],
                        width: min(constraints.maxWidth * 0.3, 360),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Slowly drifting plus signs and dots behind the orbit.
class _OrbitBackdropWidget extends StatefulWidget {
  const _OrbitBackdropWidget({required this.color, required this.isVisible});

  final Color color;
  final bool isVisible;

  @override
  State<_OrbitBackdropWidget> createState() => _OrbitBackdropWidgetState();
}

class _OrbitBackdropWidgetState extends State<_OrbitBackdropWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: 60.seconds,
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _OrbitBackdropPainter(
              color: widget.color,
              progress: _controller.value,
            ),
            size: Size.infinite,
          ),
        ).animate(target: widget.isVisible ? 1 : 0).fadeIn(duration: 800.ms),
      ),
    );
  }
}

enum _BackdropShape { plus, dot }

class _BackdropItem {
  const _BackdropItem(this.shape, this.x, this.y, this.size, this.phase);

  final _BackdropShape shape;

  /// Resting position as a fraction of the width and height.
  final double x;
  final double y;
  final double size;
  final double phase;
}

class _OrbitBackdropPainter extends CustomPainter {
  const _OrbitBackdropPainter({required this.color, required this.progress});

  final Color color;

  /// Progress of one 60 second loop, from 0 to 1.
  final double progress;

  static const _items = [
    _BackdropItem(_BackdropShape.plus, 0.16, 0.7, 14, 0.2),
    _BackdropItem(_BackdropShape.dot, 0.05, 0.5, 6, 0.4),
    _BackdropItem(_BackdropShape.plus, 0.2, 0.12, 12, 0.8),
    _BackdropItem(_BackdropShape.plus, 0.84, 0.3, 16, 0.3),
    _BackdropItem(_BackdropShape.dot, 0.95, 0.45, 7, 0.5),
    _BackdropItem(_BackdropShape.dot, 0.86, 0.9, 5, 0.7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..color = color.withAlpha(70);
    final fill = Paint()..color = color.withAlpha(90);

    for (final item in _items) {
      final angle = (progress + item.phase) * 2 * pi;
      // Each shape drifts on a small ellipse and, when it can, spins.
      final center =
          Offset(item.x * size.width, item.y * size.height) +
          Offset(cos(angle), sin(angle * 2)) * 14;

      switch (item.shape) {
        case _BackdropShape.dot:
          canvas.drawCircle(center, item.size / 2, fill);
        case _BackdropShape.plus:
          canvas
            ..save()
            ..translate(center.dx, center.dy)
            ..rotate(angle * 2)
            ..drawLine(Offset(-item.size, 0), Offset(item.size, 0), stroke)
            ..drawLine(Offset(0, -item.size), Offset(0, item.size), stroke)
            ..restore();
      }
    }
  }

  @override
  bool shouldRepaint(_OrbitBackdropPainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}

/// The expertise screen's bar chart for the selected expertise, one bar per
/// skill sized by its years of experience.
class _OrbitStatsChartWidget extends StatefulWidget {
  const _OrbitStatsChartWidget({required this.expertise, required this.width});

  final ExpertiseEntity expertise;
  final double width;

  @override
  State<_OrbitStatsChartWidget> createState() => _OrbitStatsChartWidgetState();
}

class _OrbitStatsChartWidgetState extends State<_OrbitStatsChartWidget> {
  static const _builder = ExpertiseStatsLottieBuilder();

  ExpertiseEntity? _expertise;
  Color? _color;
  Uint8List? _animation;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final color = palette.brand.primary.color;
    if (_animation == null ||
        _color != color ||
        _expertise != widget.expertise) {
      _color = color;
      _expertise = widget.expertise;
      _animation = _builder.build(
        widget.expertise,
        color: color,
        accent: palette.brand.tertiary.color,
      );
    }

    return Opacity(
      opacity: 0.22,
      child: SizedBox(
        width: widget.width,
        child: DSLottieDataWidget(data: _animation!),
      ),
    );
  }
}
