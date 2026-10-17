part of 'expertise_orbit_widget.dart';

/// Slowly counter-rotating dotted rings inside the orbit, with a small
/// satellite travelling along the node ring.
class _OrbitSpinnerWidget extends StatefulWidget {
  const _OrbitSpinnerWidget({required this.layout, required this.color});

  final _OrbitLayout layout;
  final Color color;

  @override
  State<_OrbitSpinnerWidget> createState() => _OrbitSpinnerWidgetState();
}

class _OrbitSpinnerWidgetState extends State<_OrbitSpinnerWidget>
    with SingleTickerProviderStateMixin {
  static const _loopSeconds = 40.0;

  final _turns = ValueNotifier<double>(0);
  late final _ticker = createTicker(_onTick);
  Duration _last = Duration.zero;

  @override
  void initState() {
    super.initState();
    _ticker.start();
  }

  void _onTick(Duration elapsed) {
    final delta = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _turns.value = (_turns.value + delta / _loopSeconds) % 1;
  }

  @override
  void dispose() {
    _ticker.dispose();
    _turns.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: ValueListenableBuilder<double>(
          valueListenable: _turns,
          builder: (context, turns, _) => CustomPaint(
            size: Size.square(widget.layout.side),
            painter: _OrbitSpinnerPainter(
              layout: widget.layout,
              color: widget.color,
              turns: turns,
            ),
          ),
        ),
      ),
    );
  }
}

class _OrbitSpinnerPainter extends CustomPainter {
  const _OrbitSpinnerPainter({
    required this.layout,
    required this.color,
    required this.turns,
  });

  final _OrbitLayout layout;
  final Color color;

  /// Progress of one full 40 second loop, from 0 to 1.
  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    final innerRadius = layout.radius - layout.nodeSize * 1.05;
    _dots(canvas, innerRadius, count: 48, direction: 1, speed: 1, alpha: 90);
    _dots(
      canvas,
      innerRadius * 0.82,
      count: 32,
      direction: -1,
      speed: 2,
      alpha: 60,
    );
    _satellite(canvas);
  }

  void _dots(
    Canvas canvas,
    double radius, {
    required int count,
    required int direction,
    required int speed,
    required int alpha,
  }) {
    final paint = Paint()..color = color.withAlpha(alpha);
    final dotRadius = max(1.0, layout.side * 0.004);
    final start = direction * speed * turns * 2 * pi;
    for (var index = 0; index < count; index++) {
      final angle = start + 2 * pi * index / count;
      canvas.drawCircle(
        layout.center + Offset(cos(angle), sin(angle)) * radius,
        dotRadius,
        paint,
      );
    }
  }

  void _satellite(Canvas canvas) {
    final head = turns * 2 * pi * 4 - pi / 2;
    const trail = 10;
    for (var step = 0; step < trail; step++) {
      final angle = head - step * 0.05;
      final fade = 1 - step / trail;
      canvas.drawCircle(
        layout.center + Offset(cos(angle), sin(angle)) * layout.radius,
        layout.side * 0.007 * fade + 1,
        Paint()..color = color.withAlpha((230 * fade).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_OrbitSpinnerPainter oldDelegate) {
    return turns != oldDelegate.turns ||
        color != oldDelegate.color ||
        layout.side != oldDelegate.layout.side;
  }
}
