part of 'expertise_orbit_widget.dart';

/// Where the nodes and arcs sit for a given size and domain count.
class _OrbitLayout {
  _OrbitLayout(this.side, this.count);

  /// How much larger the selected node is than the others.
  static const selectedScale = 1.4;

  final double side;
  final int count;

  Offset get center => Offset(side / 2, side / 2);

  double get nodeSize => min(side * 0.15, side * 2.5 / count * 0.62);

  /// Radius of the circle the nodes sit on, leaving room for the selected
  /// node's size and lift.
  double get radius => side / 2 - nodeSize * (selectedScale / 2 + 0.15);

  double get centerWidth => radius * 1.15;

  double get segmentAngle => 2 * pi / count;

  double midAngle(int index) => -pi / 2 + segmentAngle * (index + 0.5);

  /// Angle an arc keeps clear of a node's centre, room for the node and the
  /// arc's rounded cap.
  double clearanceOf({required bool isSelected}) {
    final halfSize = isSelected ? selectedScale / 2 : 0.5;
    return nodeSize * (halfSize + 0.06) / radius + 0.05;
  }

  Offset nodeOffset(int index) {
    final angle = midAngle(index);
    return Offset(cos(angle), sin(angle)) * radius;
  }

  /// The segment under [position], or null when it is off the node band.
  int? indexAt(Offset position) {
    final offset = position - center;
    if ((offset.distance - radius).abs() > nodeSize * 0.9) return null;
    final angle = (atan2(offset.dy, offset.dx) + pi / 2) % (2 * pi);
    return (angle / segmentAngle).floor() % count;
  }
}

class _OrbitArcsPainter extends CustomPainter {
  const _OrbitArcsPainter({
    required this.layout,
    required this.color,
    required this.selected,
    required this.progress,
  });

  final _OrbitLayout layout;
  final Color color;
  final int selected;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final count = layout.count;
    final rect = Rect.fromCircle(center: layout.center, radius: layout.radius);
    for (var index = 0; index < count; index++) {
      final next = (index + 1) % count;
      final isLit = index == selected || next == selected;
      // Arcs run between neighbouring nodes, leaving room for each node.
      final startClearance = layout.clearanceOf(isSelected: index == selected);
      final start = layout.midAngle(index) + startClearance;
      final sweep =
          layout.segmentAngle -
          startClearance -
          layout.clearanceOf(isSelected: next == selected);
      if (count < 2 || sweep <= 0) continue;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = layout.side * (isLit ? 0.008 + 0.006 * progress : 0.006)
        ..color = color.withAlpha(isLit ? 255 : 80);

      if (isLit) {
        final glow = Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = paint.strokeWidth * 3
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
          ..color = color.withAlpha((120 * progress).round());
        canvas.drawArc(rect, start, sweep, false, glow);
      }
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_OrbitArcsPainter oldDelegate) {
    return selected != oldDelegate.selected ||
        progress != oldDelegate.progress ||
        layout.side != oldDelegate.layout.side ||
        color != oldDelegate.color;
  }
}
