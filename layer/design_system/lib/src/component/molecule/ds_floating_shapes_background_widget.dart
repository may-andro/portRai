import 'dart:math' as math;

import 'package:design_system/src/component/atom/container/ds_visibility_detector_widget.dart';
import 'package:flutter/material.dart';

/// A decorative, non-interactive background of softly drifting rings, dots,
/// plus signs and diamonds, painted in a single [color].
///
/// Typically placed as the first child of a [Stack] and sized by its parent.
class DSFloatingShapesBackgroundWidget extends StatefulWidget {
  const DSFloatingShapesBackgroundWidget({
    super.key,
    required this.color,
    this.shapeCount = 16,
    this.duration = const Duration(seconds: 24),
  });

  final Color color;
  final int shapeCount;
  final Duration duration;

  @override
  State<DSFloatingShapesBackgroundWidget> createState() {
    return _DSFloatingShapesBackgroundWidgetState();
  }
}

class _DSFloatingShapesBackgroundWidgetState
    extends State<DSFloatingShapesBackgroundWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..repeat();

  final _visibilityKey = UniqueKey();
  bool _isOnScreen = true;

  // Stops the loop while none of the widget is on screen, so it stops
  // requesting frames once it is scrolled away.
  void _onVisibilityChanged(double visiblePercentage) {
    if (!mounted) return;
    _isOnScreen = visiblePercentage > 0;
    if (!_isOnScreen) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  late final List<_Shape> _shapes = _Shape.generate(widget.shapeCount);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DSVisibilityDetectorWidget(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(
            painter: _ShapesPainter(_shapes, widget.color, _controller),
            size: Size.infinite,
          ),
        ),
      ),
    );
  }
}

enum _ShapeType { ring, dot, plus, diamond }

class _Shape {
  const _Shape({
    required this.type,
    required this.x,
    required this.y,
    required this.size,
    required this.phase,
    required this.drift,
  });

  final _ShapeType type;
  final double x;
  final double y;
  final double size;
  final double phase;
  final double drift;

  static List<_Shape> generate(int count) {
    final random = math.Random(7);
    return List.generate(count, (index) {
      return _Shape(
        type: _ShapeType.values[index % _ShapeType.values.length],
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 8 + random.nextDouble() * 18,
        phase: random.nextDouble(),
        drift: 10 + random.nextDouble() * 22,
      );
    });
  }
}

class _ShapesPainter extends CustomPainter {
  _ShapesPainter(this.shapes, this.color, this.animation)
    : super(repaint: animation);

  final List<_Shape> shapes;
  final Color color;
  final Animation<double> animation;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = color.withAlpha(70)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    final fill = Paint()..color = color.withAlpha(50);

    for (final shape in shapes) {
      final angle = 2 * math.pi * (animation.value + shape.phase);
      final center = Offset(
        shape.x * size.width + math.cos(angle) * shape.drift,
        shape.y * size.height + math.sin(angle) * shape.drift,
      );
      final r = shape.size / 2;

      switch (shape.type) {
        case _ShapeType.ring:
          canvas.drawCircle(center, r, stroke);
        case _ShapeType.dot:
          canvas.drawCircle(center, r / 2, fill);
        case _ShapeType.plus:
          canvas
            ..save()
            ..translate(center.dx, center.dy)
            ..rotate(angle)
            ..drawLine(Offset(-r, 0), Offset(r, 0), stroke)
            ..drawLine(Offset(0, -r), Offset(0, r), stroke)
            ..restore();
        case _ShapeType.diamond:
          canvas
            ..save()
            ..translate(center.dx, center.dy)
            ..rotate(math.pi / 4 + angle)
            ..drawRect(
              Rect.fromCircle(center: Offset.zero, radius: r * 0.7),
              stroke,
            )
            ..restore();
      }
    }
  }

  @override
  bool shouldRepaint(_ShapesPainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.shapes != shapes;
  }
}
