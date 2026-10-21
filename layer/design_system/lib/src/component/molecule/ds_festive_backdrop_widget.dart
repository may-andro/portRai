import 'dart:math' as math;

import 'package:design_system/src/component/atom/container/ds_visibility_detector_widget.dart';
import 'package:design_system/src/design_system/design_system.dart';
import 'package:design_system/src/extension/build_context_extension.dart';
import 'package:flutter/material.dart';

enum DSFestiveBackdropShape { circle, rectangle }

/// A backdrop (circular or rectangular) whose animated decoration reflects the active
/// [DesignSystem] festival (snow for xmas, lanterns for diwali, colour splashes
/// for holi, ghosts and pumpkins for halloween, petals for sakura, and so on).
///
/// Size is driven by the parent constraints, so wrap it in a sized box.
class DSFestiveBackdropWidget extends StatefulWidget {
  const DSFestiveBackdropWidget({
    super.key,
    this.shape = DSFestiveBackdropShape.circle,
    this.designSystem,
    this.duration = const Duration(seconds: 12),
    this.particleCount = 28,
    this.effectOpacity = 1,
  });

  /// Circle draws the brand gradient disc; rectangle only draws the effect
  /// over the parent's background, which suits full-width sections.
  final DSFestiveBackdropShape shape;

  /// Overrides the festival taken from the ambient theme.
  final DesignSystem? designSystem;

  /// Duration of one animation loop.
  final Duration duration;

  /// Number of particles drawn by the effect.
  final int particleCount;

  /// Opacity of the animated effect, from 0 (hidden) to 1 (fully visible).
  final double effectOpacity;

  @override
  State<DSFestiveBackdropWidget> createState() =>
      _DSFestiveBackdropWidgetState();
}

class _DSFestiveBackdropWidgetState extends State<DSFestiveBackdropWidget>
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

  late List<_Particle> _particles = _generate();

  List<_Particle> _generate() {
    final random = math.Random(7);
    return List.generate(
      widget.particleCount,
      (index) => _Particle(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: 0.4 + random.nextDouble() * 0.6,
        speed: 1 + random.nextInt(3),
        phase: random.nextDouble(),
        colorIndex: random.nextInt(1000),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant DSFestiveBackdropWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.duration != widget.duration) {
      _controller.duration = widget.duration;
      if (_isOnScreen) _controller.repeat();
    }
    if (oldWidget.particleCount != widget.particleCount) {
      _particles = _generate();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final designSystem = widget.designSystem ?? context.theme.designSystem;
    final primary = context.colorPalette.brand.primary.color;
    return DSVisibilityDetectorWidget(
      key: _visibilityKey,
      onVisibilityChanged: _onVisibilityChanged,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.shape == DSFestiveBackdropShape.circle)
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primary, primary.withAlpha(50)],
                ),
              ),
            ),
          Opacity(
            opacity: widget.effectOpacity,
            child: RepaintBoundary(
              child: CustomPaint(
                painter: _FestivePainter(
                  rectangular: widget.shape == DSFestiveBackdropShape.rectangle,
                  effect: _effectFor(designSystem),
                  particles: _particles,
                  repaint: _controller,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _Effect {
  snow,
  diwali,
  splashes,
  spooky,
  petals,
  fireworks,
  confetti,
  leaves,
  fireflies,
  sparks,
  meadow,
  weave,
}

_Effect _effectFor(DesignSystem designSystem) {
  switch (designSystem) {
    case DesignSystem.xmas:
      return _Effect.snow;
    case DesignSystem.diwali:
      return _Effect.diwali;
    case DesignSystem.holi:
      return _Effect.splashes;
    case DesignSystem.halloween:
      return _Effect.spooky;
    case DesignSystem.sakura:
      return _Effect.petals;
    case DesignSystem.hogmanay:
      return _Effect.fireworks;
    case DesignSystem.carnival:
      return _Effect.confetti;
    case DesignSystem.chuseok:
      return _Effect.leaves;
    case DesignSystem.obon:
      return _Effect.fireflies;
    case DesignSystem.beltane:
      return _Effect.meadow;
    case DesignSystem.hogeras:
      return _Effect.sparks;
    case DesignSystem.pachamama:
      return _Effect.weave;
  }
}

class _Particle {
  const _Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
    required this.colorIndex,
  });

  final double x;
  final double y;
  final double size;

  /// Whole number of loops per cycle, so the animation wraps seamlessly.
  final int speed;
  final double phase;
  final int colorIndex;
}

class _FestivePainter extends CustomPainter {
  _FestivePainter({
    required this.rectangular,
    required this.effect,
    required this.particles,
    required Animation<double> repaint,
  }) : _progress = repaint,
       super(repaint: repaint);

  final bool rectangular;
  final _Effect effect;
  final List<_Particle> particles;
  final Animation<double> _progress;

  static const _twoPi = 2 * math.pi;
  static const _holiColors = [
    Color(0xFFE91E63),
    Color(0xFFFFEB3B),
    Color(0xFF00BCD4),
    Color(0xFF8BC34A),
    Color(0xFFFF5722),
    Color(0xFF9C27B0),
  ];
  static const _carnivalColors = [
    Color(0xFFC2185B),
    Color(0xFFE0A63A),
    Color(0xFF1AA6A0),
    Color(0xFF6A1B9A),
  ];
  static const _petalColors = [Color(0xFFFFB7C5), Color(0xFFFF8FAB)];
  static const _leafColors = [
    Color(0xFFE65100),
    Color(0xFFBF360C),
    Color(0xFFFFA000),
  ];
  static const _warmEmbers = [Color(0xFFFF5722), Color(0xFFFFC107)];
  static const _fireflyColors = [Color(0xFFE6EE9C), Color(0xFFFFF59D)];

  @override
  void paint(Canvas canvas, Size size) {
    final progress = _progress.value;
    canvas.save();
    canvas.clipPath(
      rectangular
          ? (Path()..addRect(Offset.zero & size))
          : (Path()..addOval(Offset.zero & size)),
    );
    switch (effect) {
      case _Effect.snow:
        _paintHangingOrnaments(canvas, size, progress);
      case _Effect.petals:
        _paintBranch(canvas, size, progress);
        _paintFalling(
          canvas,
          size,
          progress,
          _petalColors,
          _Shape.blossomPetal,
        );
      case _Effect.leaves:
        _paintFalling(
          canvas,
          size,
          progress,
          _leafColors,
          _Shape.leaf,
          limit: 14,
        );
      case _Effect.confetti:
        _paintRibbons(canvas, size, progress);
        _paintMask(canvas, size, progress);
        _paintFalling(
          canvas,
          size,
          progress,
          _carnivalColors,
          _Shape.strip,
          limit: 16,
        );
      case _Effect.diwali:
        _paintRangoli(canvas, size, progress);
        _paintRising(canvas, size, progress, _warmEmbers);
        _paintDiyas(canvas, size, progress);
      case _Effect.sparks:
        _paintFlames(canvas, size, progress);
        _paintRising(canvas, size, progress, _warmEmbers);
      case _Effect.fireflies:
        _paintRising(canvas, size, progress, _fireflyColors);
        _paintFloatingLanterns(canvas, size, progress);
      case _Effect.meadow:
        _paintBeltane(canvas, size, progress);
      case _Effect.splashes:
        _paintSplashes(canvas, size, progress);
      case _Effect.fireworks:
        _paintFireworks(canvas, size, progress);
      case _Effect.weave:
        _paintAndean(canvas, size, progress);
      case _Effect.spooky:
        _paintHalloween(canvas, size, progress);
    }
    canvas.restore();

    // Glyphs may overflow the circle, so they are drawn unclipped.
    final glyphs = _glyphsFor(effect);
    if (glyphs.isNotEmpty) {
      _paintGlyphs(canvas, size, progress, glyphs);
    }
  }

  List<String> _glyphsFor(_Effect effect) {
    switch (effect) {
      case _Effect.diwali:
        return const [];
      case _Effect.spooky:
        return const [];
      case _Effect.fireflies:
        return const [];
      case _Effect.confetti:
        return const [];
      case _Effect.leaves:
        return const ['🌕'];
      case _Effect.sparks:
        return const [];
      case _Effect.meadow:
        return const [];
      case _Effect.weave:
        return const [];
      case _Effect.fireworks:
        return const [];
      case _Effect.petals:
        return const [];
      case _Effect.snow:
        return const [];
      case _Effect.splashes:
        return const [];
    }
  }

  void _paintFalling(
    Canvas canvas,
    Size size,
    double progress,
    List<Color> colors,
    _Shape shape, {
    int? limit,
  }) {
    for (final particle in particles.take(limit ?? particles.length)) {
      final fall = (particle.y + progress * particle.speed) % 1;
      final angle = (progress * particle.speed + particle.phase) * _twoPi;
      final center = Offset(
        (particle.x + math.sin(angle) * 0.04) * size.width,
        fall * size.height,
      );
      final radius = size.shortestSide * 0.012 * (1 + particle.size * 2);
      final paint = Paint()
        ..color = colors[particle.colorIndex % colors.length].withValues(
          alpha: 0.9,
        );
      switch (shape) {
        case _Shape.dot:
          canvas.drawCircle(center, radius, paint);
        case _Shape.petal:
          canvas.save();
          canvas
            ..translate(center.dx, center.dy)
            ..rotate(angle);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: radius * 2.4,
              height: radius * 1.4,
            ),
            paint,
          );
          canvas.restore();
        case _Shape.blossomPetal:
          canvas.save();
          canvas
            ..translate(center.dx, center.dy)
            ..rotate(angle)
            ..scale(1, 0.45 + 0.55 * math.cos(angle * 2).abs());
          canvas.drawPath(_petalPath(radius * 2.2, radius * 2.8), paint);
          canvas.restore();
        case _Shape.leaf:
          canvas.save();
          canvas
            ..translate(center.dx, center.dy)
            ..rotate(angle)
            ..scale(0.5 + 0.5 * math.cos(angle * 2).abs(), 1);
          final length = radius * 3.4;
          final half = radius * 1.1;
          canvas.drawPath(
            Path()
              ..moveTo(0, -length / 2)
              ..quadraticBezierTo(half * 1.6, -length * 0.1, 0, length / 2)
              ..quadraticBezierTo(-half * 1.6, -length * 0.1, 0, -length / 2)
              ..close(),
            paint,
          );
          canvas.drawLine(
            Offset(0, -length / 2),
            Offset(0, length / 2 + radius * 0.4),
            Paint()
              ..color = Colors.brown.shade900.withValues(alpha: 0.4)
              ..strokeWidth = math.max(1, radius * 0.15),
          );
          canvas.restore();
        case _Shape.strip:
          canvas.save();
          canvas
            ..translate(center.dx, center.dy)
            ..rotate(angle * 2);
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: radius * 2,
              height: radius * 0.8,
            ),
            paint,
          );
          canvas.restore();
      }
    }
  }

  void _paintRising(
    Canvas canvas,
    Size size,
    double progress,
    List<Color> colors,
  ) {
    for (final particle in particles) {
      final rise = 1 - (particle.y + progress * particle.speed) % 1;
      final twinkle =
          0.5 +
          0.5 * math.sin((progress * particle.speed + particle.phase) * _twoPi);
      final paint = Paint()
        ..color = Color.lerp(
          colors.first,
          colors.last,
          particle.size,
        )!.withValues(alpha: 0.25 + 0.6 * twinkle)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(
        Offset(particle.x * size.width, rise * size.height),
        size.shortestSide * 0.01 * (1 + particle.size * 2),
        paint,
      );
    }
  }

  void _paintSplashes(Canvas canvas, Size size, double progress) {
    // Fixed, well separated spots keep the splats from touching each other.
    const anchors = [
      Offset(0.08, 0.3),
      Offset(0.3, 0.72),
      Offset(0.52, 0.3),
      Offset(0.74, 0.72),
      Offset(0.94, 0.3),
    ];
    for (var index = 0; index < anchors.length; index++) {
      final particle = particles[index];
      final pulse =
          0.9 +
          0.1 * math.sin((progress * particle.speed + particle.phase) * _twoPi);
      final color = _holiColors[index % _holiColors.length];
      final center = Offset(
        anchors[index].dx * size.width,
        anchors[index].dy * size.height,
      );
      final radius = size.shortestSide * 0.045 * (1 + particle.size) * pulse;
      // A single filled path avoids darker overlaps without needing a layer.
      canvas.drawPath(
        _splatPath(center, radius, particle.phase),
        Paint()..color = color.withValues(alpha: 0.6),
      );
    }
  }

  /// A liquid splat: one smooth outline whose radius is a round core plus
  /// narrow rounded lobes of uneven length, with the droplets flung around it.
  Path _splatPath(Offset center, double radius, double seed) {
    const arms = 10;
    const droplets = 7;
    const samples = 240;
    final lobeAngles = List.generate(arms, (arm) {
      final hash = (seed * 89 + arm * 0.618) % 1;
      return (arm + hash * 0.4) / arms * _twoPi;
    });
    final lobeLengths = List.generate(arms, (arm) {
      return radius * (0.6 + 0.9 * ((seed * 89 + arm * 0.618) * 5 % 1));
    });
    final lobeWidths = List.generate(arms, (arm) {
      return 0.17 + 0.07 * ((seed * 31 + arm * 0.41) % 1);
    });

    final path = Path();
    for (var sample = 0; sample <= samples; sample++) {
      final angle = sample / samples * _twoPi;
      var distance = radius;
      for (var arm = 0; arm < arms; arm++) {
        var delta = (angle - lobeAngles[arm]).abs() % _twoPi;
        if (delta > math.pi) {
          delta = _twoPi - delta;
        }
        final ratio = delta / lobeWidths[arm];
        distance += lobeLengths[arm] * math.exp(-ratio * ratio * ratio);
      }
      final point =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      if (sample == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    Path rotated(Path shape, Offset origin, double angle) {
      final matrix = Matrix4.identity()
        ..translateByDouble(origin.dx, origin.dy, 0, 1)
        ..rotateZ(angle);
      return shape.transform(matrix.storage);
    }

    for (var drop = 0; drop < droplets; drop++) {
      final hash = (seed * 53 + drop * 0.37) % 1;
      final angle = (drop + hash * 0.6) / droplets * _twoPi;
      final distance = radius * (2.6 + hash * 0.7);
      final droplet = Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: radius * (0.3 + 0.25 * hash),
            height: radius * 0.22,
          ),
        );
      final origin =
          center + Offset(math.cos(angle), math.sin(angle)) * distance;
      path.addPath(rotated(droplet, origin, angle), Offset.zero);
    }
    return path;
  }

  void _paintFloatingLanterns(Canvas canvas, Size size, double progress) {
    const palette = [
      Color(0xFFD84315),
      Color(0xFFEF6C00),
      Color(0xFFC62828),
      Color(0xFFFFB300),
    ];
    const count = 6;
    final unit = size.shortestSide;
    for (var index = 0; index < count; index++) {
      final hash = (index * 0.618 + 0.13) % 1;
      // Each lantern drifts up once per loop, offset from the others.
      final t = (progress + index / count) % 1;
      final fade = math.sin(t * math.pi);
      final width = unit * (0.07 + 0.06 * hash);
      final height = width * 1.3;
      final sway = math.sin((t * 2 + hash) * _twoPi) * unit * 0.03;
      final center = Offset(
        ((index + 0.5) / count + (hash - 0.5) * 0.06) * size.width + sway,
        size.height * (1.1 - 1.2 * t),
      );
      final color = palette[index % palette.length];

      canvas.drawCircle(
        center,
        width * 1.7,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFE082).withValues(alpha: 0.5 * fade),
              const Color(0x00FFE082),
            ],
          ).createShader(Rect.fromCircle(center: center, radius: width * 1.7)),
      );

      final body = RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: width, height: height),
        Radius.circular(width * 0.35),
      );
      canvas.drawRRect(
        body,
        Paint()
          ..shader = RadialGradient(
            colors: [
              const Color(0xFFFFF3C4).withValues(alpha: fade),
              color.withValues(alpha: 0.9 * fade),
            ],
          ).createShader(body.outerRect),
      );
      final rib = Paint()
        ..color = const Color(0xFF5D1A0A).withValues(alpha: 0.35 * fade)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, width * 0.025);
      for (final fraction in const [-0.25, 0, 0.25]) {
        canvas.drawLine(
          center + Offset(width * fraction, -height * 0.5),
          center + Offset(width * fraction, height * 0.5),
          rib,
        );
      }
      final cap = Paint()
        ..color = const Color(0xFF3E2723).withValues(alpha: 0.8 * fade);
      for (final side in const [-1.0, 1.0]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: center + Offset(0, side * height * 0.5),
              width: width * 0.5,
              height: height * 0.1,
            ),
            Radius.circular(width * 0.05),
          ),
          cap,
        );
      }
    }
  }

  static const _ornamentRed = Color(0xFFC0392B);
  static const _ornamentNavy = Color(0xFF1F3049);

  /// Flat, two-tone ornaments (baubles, trees, gifts, snowflakes) hanging on
  /// strings of different lengths, swaying gently, among tiny stars and dots.
  void _paintHangingOrnaments(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    final baseSize = unit * 0.14;
    final count = (size.width / (baseSize * 3)).round().clamp(4, 10);
    final ornamentSize = math.min(baseSize, size.width / count * 0.5);
    const lengths = [0.2, 0.4, 0.28, 0.52, 0.34, 0.62, 0.24, 0.46, 0.36, 0.56];
    for (var index = 0; index < count; index++) {
      final color = index.isEven ? _ornamentNavy : _ornamentRed;
      // Alternating colours with a shifting type keeps neighbours different.
      final kind = (index * 3 + index ~/ 4) % 4;
      final swing =
          math.sin((progress * (1 + index % 2) + index * 0.19) * _twoPi) * 0.05;
      final length = size.height * lengths[index] * 0.85;
      canvas.save();
      canvas
        ..translate((index + 0.5) / count * size.width, 0)
        ..rotate(swing);
      final stringPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..strokeWidth = math.max(1, ornamentSize * 0.025);
      canvas.drawLine(Offset.zero, Offset(0, length), stringPaint);
      canvas.translate(0, length);
      _drawOrnament(canvas, kind, ornamentSize, color);
      canvas.restore();
    }

    for (var index = 0; index < math.min(16, particles.length); index++) {
      final particle = particles[index];
      final color = index.isEven ? _ornamentRed : _ornamentNavy;
      final twinkle =
          0.6 + 0.4 * math.sin((progress * 2 + particle.phase) * _twoPi);
      final center = Offset(particle.x * size.width, particle.y * size.height);
      final paint = Paint()..color = color.withValues(alpha: 0.85 * twinkle);
      final radius = unit * (0.008 + 0.014 * particle.size);
      if (index % 3 == 0) {
        canvas.drawPath(_starPath(center, radius * 1.8), paint);
      } else {
        canvas.drawCircle(center, radius * 0.6, paint);
      }
    }
  }

  Path _starPath(Offset center, double outer) {
    final path = Path();
    for (var point = 0; point < 10; point++) {
      final radius = point.isEven ? outer : outer * 0.45;
      final angle = -math.pi / 2 + point * math.pi / 5;
      final offset = center + Offset(math.cos(angle), math.sin(angle)) * radius;
      if (point == 0) {
        path.moveTo(offset.dx, offset.dy);
      } else {
        path.lineTo(offset.dx, offset.dy);
      }
    }
    return path..close();
  }

  /// Draws one ornament with its top at the origin.
  void _drawOrnament(Canvas canvas, int kind, double s, Color color) {
    final fill = Paint()..color = color;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = math.max(1, s * 0.05);
    final light = Paint()..color = Colors.white.withValues(alpha: 0.9);

    void snowflake(Offset center, double radius) {
      for (var arm = 0; arm < 6; arm++) {
        final angle = arm / 6 * _twoPi;
        final direction = Offset(math.cos(angle), math.sin(angle));
        canvas.drawLine(center, center + direction * radius, stroke);
        final branchBase = center + direction * radius * 0.6;
        for (final side in const [-1.0, 1.0]) {
          final branch = angle + side * 0.7;
          canvas.drawLine(
            branchBase,
            branchBase +
                Offset(math.cos(branch), math.sin(branch)) * radius * 0.35,
            stroke,
          );
        }
      }
    }

    switch (kind) {
      case 0: // bauble
        final center = Offset(0, s * 0.62);
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset(0, s * 0.06),
            width: s * 0.22,
            height: s * 0.12,
          ),
          fill,
        );
        canvas.drawCircle(center, s * 0.5, light);
        canvas.drawCircle(
          center,
          s * 0.5,
          stroke..strokeWidth = math.max(2, s * 0.08),
        );
        stroke.strokeWidth = math.max(1, s * 0.03);
        snowflake(center, s * 0.3);
      case 1: // tree
        final height = s * 1.3;
        for (var tier = 0; tier < 3; tier++) {
          final top = height * tier * 0.26;
          final halfWidth = s * (0.26 + 0.14 * tier);
          final tierPath = Path()
            ..moveTo(0, top)
            ..lineTo(halfWidth, top + height * 0.38)
            ..lineTo(-halfWidth, top + height * 0.38)
            ..close();
          canvas.drawPath(tierPath, fill);
          canvas.drawPath(tierPath, stroke..strokeWidth = s * 0.05);
        }
        canvas.drawRect(
          Rect.fromLTWH(-s * 0.07, height * 0.97, s * 0.14, s * 0.14),
          fill,
        );
      case 2: // gift
        stroke.strokeWidth = math.max(1, s * 0.04);
        for (final side in const [-1.0, 1.0]) {
          canvas.save();
          canvas
            ..translate(side * s * 0.13, s * 0.15)
            ..rotate(side * 0.6);
          canvas.drawOval(
            Rect.fromCenter(
              center: Offset.zero,
              width: s * 0.26,
              height: s * 0.13,
            ),
            stroke,
          );
          canvas.restore();
        }
        canvas.drawRect(
          Rect.fromLTWH(-s * 0.48, s * 0.26, s * 0.96, s * 0.2),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTWH(-s * 0.4, s * 0.5, s * 0.8, s * 0.62),
          fill,
        );
        canvas.drawRect(
          Rect.fromLTWH(-s * 0.03, s * 0.26, s * 0.06, s * 0.86),
          light,
        );
      default: // snowflake
        stroke.strokeWidth = math.max(1, s * 0.045);
        final center = Offset(0, s * 0.5);
        snowflake(center, s * 0.5);
        canvas.drawCircle(center, s * 0.06, stroke);
    }
  }

  /// A rangoli peeking in from the right edge: only its left half is visible.
  void _paintRangoli(Canvas canvas, Size size, double progress) {
    final radius = size.shortestSide * 0.4;
    canvas.save();
    canvas
      ..translate(size.width, size.height * 0.3)
      ..rotate(progress * _twoPi);

    const points = 9;
    final star = Path();
    for (var point = 0; point < points * 2; point++) {
      final length = point.isEven ? radius : radius * 0.7;
      final angle = point * math.pi / points;
      final offset = Offset(math.cos(angle), math.sin(angle)) * length;
      if (point == 0) {
        star.moveTo(offset.dx, offset.dy);
      } else {
        star.lineTo(offset.dx, offset.dy);
      }
    }
    star.close();
    canvas.drawPath(star, Paint()..color = const Color(0xFFD81B60));

    final petal = Paint()..color = const Color(0xFFFB8C00);
    for (var point = 0; point < points; point++) {
      canvas.save();
      canvas
        ..rotate(point / points * _twoPi)
        ..translate(radius * 0.8, 0);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.2,
          height: radius * 0.09,
        ),
        petal,
      );
      canvas.restore();
    }

    canvas.drawCircle(
      Offset.zero,
      radius * 0.55,
      Paint()..color = const Color(0xFF3D9BD8),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.55,
      Paint()
        ..color = const Color(0xFFE6C619)
        ..style = PaintingStyle.stroke
        ..strokeWidth = radius * 0.04,
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.4,
      Paint()..color = const Color(0xFFC0392B),
    );
    final dot = Paint()..color = Colors.white;
    for (var index = 0; index < 16; index++) {
      final angle = index / 16 * _twoPi;
      canvas.drawCircle(
        Offset(math.cos(angle), math.sin(angle)) * radius * 0.32,
        radius * 0.035,
        dot,
      );
    }
    canvas.drawCircle(
      Offset.zero,
      radius * 0.22,
      Paint()..color = const Color(0xFFF39C12),
    );
    canvas.drawCircle(
      Offset.zero,
      radius * 0.12,
      Paint()..color = const Color(0xFFF7C948),
    );
    canvas.restore();
  }

  /// Two staggered rows of lit diyas along the bottom edge.
  void _paintDiyas(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    final frontWidth = unit * 0.09;
    final count = math.max(6, (size.width / (frontWidth * 1.8)).round());
    for (var row = 0; row < 2; row++) {
      final scale = row == 0 ? 0.75 : 1.0;
      final diyaWidth = frontWidth * scale;
      final baseline = size.height - frontWidth * (row == 0 ? 0.85 : 0.2);
      for (var index = 0; index < count; index++) {
        final x = (index + (row == 0 ? 1.0 : 0.5)) / count * size.width;
        if (x > size.width + diyaWidth) {
          continue;
        }
        _drawDiya(
          canvas,
          Offset(x, baseline),
          diyaWidth,
          progress,
          index * 0.31 + row * 0.5,
        );
      }
    }
  }

  void _drawDiya(
    Canvas canvas,
    Offset base,
    double width,
    double progress,
    double phase,
  ) {
    final flicker = 0.5 + 0.5 * math.sin((progress * 3 + phase) * _twoPi);
    final flameHeight = width * (0.7 + 0.25 * flicker);
    final flameWidth = width * 0.22;
    final lean = math.sin((progress * 2 + phase) * _twoPi) * width * 0.05;

    canvas.drawCircle(
      base.translate(0, -flameHeight * 0.5),
      width * (0.9 + 0.2 * flicker),
      Paint()..color = const Color(0xFFFFC107).withValues(alpha: 0.14),
    );

    Path flame(double heightScale, double widthScale) {
      final height = flameHeight * heightScale;
      final half = flameWidth * widthScale;
      final tip = Offset(lean * heightScale, -height);
      return Path()
        ..moveTo(0, 0)
        ..cubicTo(
          half * 1.3,
          -height * 0.1,
          half,
          -height * 0.55,
          tip.dx,
          tip.dy,
        )
        ..cubicTo(-half, -height * 0.55, -half * 1.3, -height * 0.1, 0, 0)
        ..close();
    }

    canvas.save();
    canvas.translate(base.dx, base.dy - width * 0.12);
    canvas.drawPath(flame(1, 1), Paint()..color = const Color(0xFFFF9800));
    canvas.drawPath(flame(0.6, 0.55), Paint()..color = const Color(0xFFFFE082));
    canvas.restore();

    final bowl = Path()
      ..moveTo(base.dx - width / 2, base.dy - width * 0.12)
      ..quadraticBezierTo(
        base.dx - width * 0.4,
        base.dy + width * 0.28,
        base.dx,
        base.dy + width * 0.28,
      )
      ..quadraticBezierTo(
        base.dx + width * 0.4,
        base.dy + width * 0.28,
        base.dx + width / 2,
        base.dy - width * 0.12,
      )
      ..close();
    canvas.drawPath(bowl, Paint()..color = const Color(0xFFB5651D));
    canvas.drawLine(
      base.translate(-width / 2, -width * 0.12),
      base.translate(width / 2, -width * 0.12),
      Paint()
        ..color = const Color(0xFFE6B655)
        ..strokeWidth = math.max(1.5, width * 0.08)
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Long, flowing ribbons that stream down from the top-left corner.
  void _paintRibbons(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    const starts = [0.03, 0.07, 0.11];
    for (var index = 0; index < starts.length; index++) {
      final length = unit * (0.7 + 0.15 * index);
      final flow = (progress * (1 + index % 2) + index * 0.3) * _twoPi;
      final path = Path()..moveTo(starts[index] * size.width, 0);
      for (var y = 0.0; y <= length; y += 6) {
        final grow = y / length;
        path.lineTo(
          starts[index] * size.width +
              math.sin(y / unit * 7 + flow) * unit * 0.06 * grow,
          y,
        );
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = _carnivalColors[index].withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1.5, unit * 0.012),
      );
    }
  }

  /// A feathered carnival mask in the bottom-right corner.
  void _paintMask(Canvas canvas, Size size, double progress) {
    final width = math.min(size.shortestSide * 0.75, size.width * 0.4);
    final bob = math.sin(progress * _twoPi) * width * 0.015;
    canvas.save();
    canvas.translate(
      size.width - width * 0.7,
      size.height - width * 0.32 + bob,
    );

    const yellow = Color(0xFFF9C51D);
    const red = Color(0xFFD62C4B);
    const cream = Color(0xFFF2EBD8);
    const navy = Color(0xFF1B1464);

    // Feathers fan out from just above the brow.
    const feathers = [
      (angle: -1.4, length: 0.32, color: Color(0xFFE9E4D0)),
      (angle: 1.4, length: 0.32, color: Color(0xFFE9E4D0)),
      (angle: -1.1, length: 0.42, color: Color(0xFF2F80D8)),
      (angle: 1.1, length: 0.42, color: Color(0xFF2F80D8)),
      (angle: -0.72, length: 0.58, color: Color(0xFF2E9E57)),
      (angle: 0.72, length: 0.58, color: Color(0xFF2E9E57)),
      (angle: -0.34, length: 0.64, color: Color(0xFFD62C4B)),
      (angle: 0.34, length: 0.64, color: Color(0xFFD62C4B)),
      (angle: 0.0, length: 0.72, color: Color(0xFFEFEADA)),
    ];
    for (var index = 0; index < feathers.length; index++) {
      final feather = feathers[index];
      final sway = math.sin((progress + index * 0.11) * _twoPi) * 0.03;
      canvas.save();
      canvas
        ..translate(0, -width * 0.1)
        ..rotate(feather.angle + sway);
      final length = width * feather.length;
      final half = width * 0.08;
      canvas.drawPath(
        Path()
          ..moveTo(0, 0)
          ..quadraticBezierTo(half * 1.5, -length * 0.5, 0, -length)
          ..quadraticBezierTo(-half * 1.5, -length * 0.5, 0, 0)
          ..close(),
        Paint()..color = feather.color,
      );
      canvas.drawLine(
        Offset.zero,
        Offset(0, -length * 0.92),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..strokeWidth = math.max(1, width * 0.006),
      );
      canvas.restore();
    }

    // Crown of navy diamonds with gold centres.
    for (var index = -2; index <= 2; index++) {
      final lift = index.abs() == 2 ? 0.02 : (index.abs() == 1 ? 0.0 : -0.03);
      final center = Offset(index * width * 0.17, -width * (0.08 + lift));
      final diamond = width * (index == 0 ? 0.11 : 0.095);
      Path rhombus(double radius) => Path()
        ..moveTo(center.dx, center.dy - radius)
        ..lineTo(center.dx + radius, center.dy)
        ..lineTo(center.dx, center.dy + radius)
        ..lineTo(center.dx - radius, center.dy)
        ..close();
      canvas.drawPath(rhombus(diamond), Paint()..color = navy);
      canvas.drawPath(
        rhombus(diamond * 0.3),
        Paint()..color = const Color(0xFFF2B01E),
      );
    }

    // Flame-like points along the brow.
    const flames = [yellow, Color(0xFFF58220), red];
    for (var index = 0; index < 11; index++) {
      final x = (index - 5) * width * 0.085;
      final height =
          width * (0.09 + 0.03 * (index % 3)) * (1 - (index - 5).abs() * 0.08);
      canvas.drawPath(
        Path()
          ..moveTo(x - width * 0.05, -width * 0.02)
          ..lineTo(x, -width * 0.02 - height)
          ..lineTo(x + width * 0.05, -width * 0.02)
          ..close(),
        Paint()..color = flames[index % flames.length],
      );
    }

    // The mask itself: yellow edge, red band, cream face.
    final body = Path()
      ..moveTo(-width * 0.5, -width * 0.12)
      ..lineTo(0, -width * 0.01)
      ..lineTo(width * 0.5, -width * 0.12)
      ..cubicTo(
        width * 0.53,
        width * 0.22,
        width * 0.33,
        width * 0.3,
        width * 0.16,
        width * 0.2,
      )
      ..quadraticBezierTo(0, width * 0.1, -width * 0.16, width * 0.2)
      ..cubicTo(
        -width * 0.33,
        width * 0.3,
        -width * 0.53,
        width * 0.22,
        -width * 0.5,
        -width * 0.12,
      )
      ..close();
    final pivot = Offset(0, width * 0.06);
    void layer(double scale, Color color) {
      canvas.save();
      canvas
        ..translate(pivot.dx, pivot.dy)
        ..scale(scale)
        ..translate(-pivot.dx, -pivot.dy);
      canvas.drawPath(body, Paint()..color = color);
      canvas.restore();
    }

    layer(1, yellow);
    layer(0.94, red);
    layer(0.82, cream);
    for (final side in const [-1.0, 1.0]) {
      canvas.save();
      canvas
        ..translate(side * width * 0.22, width * 0.07)
        ..rotate(side * 0.18);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: width * 0.3,
          height: width * 0.11,
        ),
        Paint()..color = Colors.white,
      );
      canvas.restore();
    }
    canvas.restore();
  }

  /// A cherry-blossom petal: a rounded teardrop with the characteristic notch.
  Path _petalPath(double width, double height) {
    return Path()
      ..moveTo(0, height / 2)
      ..cubicTo(
        -width * 0.9,
        height * 0.2,
        -width * 0.7,
        -height * 0.55,
        -width * 0.12,
        -height * 0.5,
      )
      ..lineTo(0, -height * 0.38)
      ..lineTo(width * 0.12, -height * 0.5)
      ..cubicTo(
        width * 0.7,
        -height * 0.55,
        width * 0.9,
        height * 0.2,
        0,
        height / 2,
      )
      ..close();
  }

  void _paintBlossom(Canvas canvas, Offset center, double radius, double turn) {
    final petal = Paint()
      ..color = const Color(0xFFFFC1D3).withValues(alpha: 0.9);
    for (var index = 0; index < 5; index++) {
      canvas.save();
      canvas
        ..translate(center.dx, center.dy)
        ..rotate(turn + index / 5 * _twoPi)
        ..translate(0, -radius * 0.55);
      canvas.drawPath(_petalPath(radius * 0.9, radius * 1.1), petal);
      canvas.restore();
    }
    canvas.drawCircle(
      center,
      radius * 0.14,
      Paint()..color = const Color(0xFFC2185B).withValues(alpha: 0.8),
    );
  }

  /// A bare branch reaching in from the top-right corner, dotted with blossoms.
  void _paintBranch(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    final sway = math.sin(progress * _twoPi) * unit * 0.01;
    Offset at(double dx, double dy) {
      return Offset(dx * size.width + sway * dx, dy * size.height + sway);
    }

    final bark = Paint()
      ..color = const Color(0xFF5D4037).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = unit * 0.014;
    final trunk = Path()
      ..moveTo(at(1.02, 0.0).dx, at(1.02, 0.0).dy)
      ..quadraticBezierTo(
        at(0.9, 0.12).dx,
        at(0.9, 0.12).dy,
        at(0.74, 0.2).dx,
        at(0.74, 0.2).dy,
      );
    final twigs = [
      Path()
        ..moveTo(at(0.9, 0.1).dx, at(0.9, 0.1).dy)
        ..quadraticBezierTo(
          at(0.88, 0.22).dx,
          at(0.88, 0.22).dy,
          at(0.84, 0.32).dx,
          at(0.84, 0.32).dy,
        ),
      Path()
        ..moveTo(at(0.8, 0.16).dx, at(0.8, 0.16).dy)
        ..quadraticBezierTo(
          at(0.74, 0.1).dx,
          at(0.74, 0.1).dy,
          at(0.68, 0.08).dx,
          at(0.68, 0.08).dy,
        ),
    ];
    canvas.drawPath(trunk, bark);
    bark.strokeWidth = unit * 0.008;
    for (final twig in twigs) {
      canvas.drawPath(twig, bark);
    }

    const blossoms = [
      (dx: 0.96, dy: 0.05, scale: 1.0, turn: 0.2),
      (dx: 0.88, dy: 0.13, scale: 0.8, turn: 1.1),
      (dx: 0.8, dy: 0.17, scale: 1.1, turn: 0.6),
      (dx: 0.84, dy: 0.31, scale: 0.9, turn: 1.7),
      (dx: 0.74, dy: 0.2, scale: 0.7, turn: 0.9),
      (dx: 0.69, dy: 0.08, scale: 0.85, turn: 0.4),
    ];
    for (final blossom in blossoms) {
      _paintBlossom(
        canvas,
        at(blossom.dx, blossom.dy),
        unit * 0.05 * blossom.scale,
        blossom.turn,
      );
    }
  }

  void _paintBeltane(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    final bounds = Offset.zero & size;
    // Dusk sky fading into the glow of the fire.
    canvas.drawRect(
      bounds,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xCC2B2250), Color(0x002B2250)],
        ).createShader(bounds),
    );
    _paintStars(canvas, size, progress);
    _paintFireDome(canvas, size, progress);
    _paintRising(canvas, size, progress, _warmEmbers);
    _paintTreeEdge(canvas, size, left: true);
    _paintTreeEdge(canvas, size, left: false);
    _paintMeadow(canvas, size, progress);
    _paintDancers(canvas, size, progress, unit);
  }

  void _paintFireDome(Canvas canvas, Size size, double progress) {
    final center = Offset(size.width / 2, size.height * 1.02);
    final radius = math.min(size.height * 1.05, size.width * 0.42);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xF2F6D56F),
            Color(0xE6E58A28),
            Color(0xCCB03A1D),
            Color(0x00B03A1D),
          ],
          stops: [0.0, 0.45, 0.8, 1.0],
        ).createShader(Rect.fromCircle(center: center, radius: radius)),
    );
    // Wispy strands radiating outwards give the flames their licking texture.
    const strands = 70;
    for (var strand = 0; strand < strands; strand++) {
      final hash = (strand * 0.618) % 1;
      final angle = math.pi + (strand + 0.5) / strands * math.pi;
      final length = radius * (0.55 + 0.5 * hash);
      final wobble = math.sin((progress * (1 + strand % 3) + hash) * _twoPi);
      final direction = Offset(math.cos(angle), math.sin(angle));
      final normal = Offset(-direction.dy, direction.dx);
      final start = center + direction * radius * 0.25;
      final end = center + direction * length + normal * wobble * radius * 0.05;
      final control =
          center +
          direction * length * 0.65 +
          normal * (wobble + hash - 0.5) * radius * 0.12;
      canvas.drawPath(
        Path()
          ..moveTo(start.dx, start.dy)
          ..quadraticBezierTo(control.dx, control.dy, end.dx, end.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = math.max(1, radius * 0.012)
          ..color =
              (strand.isEven
                      ? const Color(0xFFFFF0A8)
                      : const Color(0xFFF2B544))
                  .withValues(alpha: 0.55),
      );
    }
  }

  void _paintTreeEdge(Canvas canvas, Size size, {required bool left}) {
    final unit = size.shortestSide;
    final paint = Paint()
      ..color = const Color(0xFF2E1612).withValues(alpha: 0.9);
    const leaves = [
      (y: 0.15, r: 0.14),
      (y: 0.4, r: 0.18),
      (y: 0.65, r: 0.15),
      (y: 0.9, r: 0.18),
    ];
    for (final leaf in leaves) {
      final edge = left ? 0.0 : size.width;
      canvas.drawCircle(
        Offset(edge, leaf.y * size.height),
        unit * leaf.r,
        paint,
      );
    }
  }

  void _paintDancers(Canvas canvas, Size size, double progress, double unit) {
    const count = 6;
    final dancerHeight = math.min(unit * 0.32, size.width * 0.14);
    final spacing = math.min(size.width / (count + 1), dancerHeight * 0.85);
    final startX = size.width / 2 - spacing * (count - 1) / 2;
    final ground = size.height * 0.98;
    final silhouette = Paint()..color = const Color(0xFF140A12);
    final armPaint = Paint()
      ..color = const Color(0xFF140A12)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = dancerHeight * 0.035;

    Offset shoulderOf(int index) {
      final bob = math.sin((progress * 2 + index * 0.17) * _twoPi).abs();
      return Offset(
        startX + index * spacing,
        ground - dancerHeight * (0.78 + 0.03 * bob),
      );
    }

    // Linked hands: neighbours alternate between raised and lowered arms.
    for (var index = 0; index < count - 1; index++) {
      final from = shoulderOf(index);
      final to = shoulderOf(index + 1);
      final raised = index.isEven;
      final middle = Offset.lerp(
        from,
        to,
        0.5,
      )!.translate(0, raised ? -dancerHeight * 0.18 : dancerHeight * 0.06);
      canvas.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(middle.dx, middle.dy, to.dx, to.dy),
        armPaint,
      );
    }

    for (var index = 0; index < count; index++) {
      final phase = (progress * 2 + index * 0.17) * _twoPi;
      final bob = math.sin(phase).abs();
      final sway = math.sin(phase) * 0.05;
      canvas
        ..save()
        ..translate(
          startX + index * spacing,
          ground - dancerHeight * 0.03 * bob,
        )
        ..scale(dancerHeight);
      final body = Path()
        ..moveTo(-0.04, -0.8)
        ..lineTo(-0.03, -0.5)
        ..cubicTo(-0.1, -0.36, -0.2 + sway, -0.14, -0.2 + sway, -0.02)
        ..quadraticBezierTo(-0.1, 0.03 + sway * 0.5, 0, -0.02)
        ..quadraticBezierTo(0.1, -0.07 - sway * 0.5, 0.2 + sway, -0.02)
        ..cubicTo(0.2 + sway, -0.14, 0.1, -0.36, 0.03, -0.5)
        ..lineTo(0.04, -0.8)
        ..close();
      canvas
        ..drawPath(body, silhouette)
        ..drawCircle(const Offset(0, -0.87), 0.05, silhouette)
        ..restore();
    }
  }

  void _paintMeadow(Canvas canvas, Size size, double progress) {
    const greens = [Color(0xFF2E7D32), Color(0xFF558B2F), Color(0xFF7CB342)];
    final unit = size.shortestSide;
    final blades = math.max(12, (size.width / (unit * 0.06)).round());
    for (var blade = 0; blade < blades; blade++) {
      final hash = (blade * 0.618) % 1;
      final x = (blade + 0.5) / blades * size.width;
      final height = unit * (0.12 + 0.2 * hash);
      final halfWidth = unit * 0.012;
      final sway =
          math.sin((progress * (1 + blade % 2) + hash) * _twoPi) * unit * 0.05;
      final path = Path()
        ..moveTo(x - halfWidth, size.height)
        ..quadraticBezierTo(
          x - halfWidth + sway * 0.3,
          size.height - height * 0.6,
          x + sway,
          size.height - height,
        )
        ..quadraticBezierTo(
          x + halfWidth + sway * 0.3,
          size.height - height * 0.6,
          x + halfWidth,
          size.height,
        )
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = greens[blade % greens.length].withValues(alpha: 0.6),
      );
    }
  }

  void _paintFlames(Canvas canvas, Size size, double progress) {
    const layers = [
      (color: Color(0xFFB71C1C), height: 0.4, speed: 1, phase: 0.0),
      (color: Color(0xFFFF6F00), height: 0.3, speed: 2, phase: 0.33),
      (color: Color(0xFFFFC107), height: 0.18, speed: 3, phase: 0.66),
    ];
    // Whole tongue counts keep the flames wrapping seamlessly across the width.
    final tongues = math.max(
      3,
      (size.width / (size.shortestSide * 0.45)).round(),
    );
    const step = 4.0;
    for (final layer in layers) {
      final path = Path()..moveTo(0, size.height);
      for (var x = 0.0; x <= size.width + step; x += step) {
        final along = x / size.width;
        final flicker = (progress * layer.speed + layer.phase) * _twoPi;
        final tongue = 0.5 + 0.5 * math.sin(along * tongues * _twoPi + flicker);
        final shimmer =
            0.65 + 0.35 * math.sin(along * tongues * 2.7 * _twoPi - flicker);
        final lift =
            size.height * layer.height * (0.3 + 0.7 * tongue * shimmer);
        path.lineTo(x, size.height - lift);
      }
      path
        ..lineTo(size.width + step, size.height)
        ..close();
      canvas.drawPath(
        path,
        Paint()..color = layer.color.withValues(alpha: 0.5),
      );
    }
  }

  void _paintFireworks(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    _paintStars(canvas, size, progress);
    // Fixed launch points; each burst has its own phase and palette.
    const bursts = [
      (
        x: 0.14,
        y: 0.34,
        phase: 0.0,
        main: Color(0xFFFFC857),
        core: Color(0xFFFFFFFF),
      ),
      (
        x: 0.5,
        y: 0.22,
        phase: 0.35,
        main: Color(0xFFE8EEF5),
        core: Color(0xFF7FB8FF),
      ),
      (
        x: 0.86,
        y: 0.36,
        phase: 0.7,
        main: Color(0xFFFF8A65),
        core: Color(0xFFFFD54F),
      ),
    ];
    for (final burst in bursts) {
      final t = (progress + burst.phase) % 1;
      final center = Offset(burst.x * size.width, burst.y * size.height);
      const launchShare = 0.22;
      if (t < launchShare) {
        // Rocket climbing from the skyline with a short glowing trail.
        final climb = Curves.easeOut.transform(t / launchShare);
        final start = Offset(center.dx, size.height * 0.9);
        final head = Offset.lerp(start, center, climb)!;
        final tail = Offset.lerp(start, center, math.max(0, climb - 0.25))!;
        canvas.drawLine(
          tail,
          head,
          Paint()
            ..color = const Color(0xFFFFE0A3).withValues(alpha: 0.8)
            ..strokeWidth = math.max(1.5, unit * 0.01)
            ..strokeCap = StrokeCap.round,
        );
        continue;
      }
      final u = (t - launchShare) / (1 - launchShare);
      final reach = unit * 0.34;
      final strokeWidth = math.max(1.5, unit * 0.009);
      final fade = math.pow(1 - u, 1.6).toDouble();
      // Outer ring droops under gravity; inner ring is smaller and faster.
      for (var ring = 0; ring < 2; ring++) {
        final sparks = ring == 0 ? 30 : 16;
        final ringReach = reach * (ring == 0 ? 1 : 0.55);
        final color = ring == 0 ? burst.main : burst.core;
        final spread = Curves.easeOutCubic.transform(u);
        final lag = Curves.easeOutCubic.transform((u - 0.18).clamp(0, 1));
        final droop = unit * 0.14 * u * u * (ring == 0 ? 1 : 0.4);
        for (var spark = 0; spark < sparks; spark++) {
          final angle = (spark + ring * 0.5) / sparks * _twoPi;
          final direction = Offset(math.cos(angle), math.sin(angle));
          final head =
              center + direction * ringReach * spread + Offset(0, droop);
          final tail =
              center + direction * ringReach * lag + Offset(0, droop * 0.7);
          // Sparks twinkle out of sync as they fade.
          final twinkle = 0.55 + 0.45 * math.sin((u * 14 + spark) * 1.7);
          final paint = Paint()
            ..color = color.withValues(alpha: fade * twinkle)
            ..strokeWidth = strokeWidth
            ..strokeCap = StrokeCap.round;
          canvas
            ..drawLine(tail, head, paint)
            ..drawCircle(head, strokeWidth * 0.9, paint);
        }
      }
      canvas.drawCircle(
        center,
        unit * 0.05 * (1 - u) * (1 - u),
        Paint()..color = Colors.white.withValues(alpha: 0.5 * (1 - u)),
      );
    }
    _paintSkyline(canvas, size);
  }

  void _paintStars(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    for (var index = 0; index < particles.length; index++) {
      final star = particles[index];
      final twinkle =
          0.3 +
          0.7 *
              (0.5 +
                  0.5 *
                      math.sin((progress * star.speed + star.phase) * _twoPi));
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height * 0.7),
        math.max(0.8, unit * 0.006 * (0.6 + star.size)),
        Paint()..color = Colors.white.withValues(alpha: 0.7 * twinkle),
      );
    }
  }

  // Edinburgh-style silhouette: castle on a crag between two spires.
  void _paintSkyline(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    final base = size.height;
    final height = unit * 0.28;
    final width = size.width;
    double x(double fraction) => fraction * width;
    final path = Path()
      ..moveTo(0, base)
      ..lineTo(0, base - height * 0.25)
      ..lineTo(x(0.06), base - height * 0.3)
      // Left spire.
      ..lineTo(x(0.09), base - height * 0.3)
      ..lineTo(x(0.1), base - height * 0.85)
      ..lineTo(x(0.11), base - height * 0.3)
      // Crag rising to the castle.
      ..lineTo(x(0.26), base - height * 0.42)
      ..lineTo(x(0.34), base - height * 0.62)
      ..lineTo(x(0.34), base - height * 0.82)
      ..lineTo(x(0.37), base - height * 0.82)
      ..lineTo(x(0.37), base - height * 0.9)
      ..lineTo(x(0.4), base - height * 0.9)
      ..lineTo(x(0.4), base - height * 0.76)
      ..lineTo(x(0.46), base - height * 0.76)
      // Castle tower with a pointed roof.
      ..lineTo(x(0.46), base - height * 0.95)
      ..lineTo(x(0.48), base - height * 1.15)
      ..lineTo(x(0.5), base - height * 0.95)
      ..lineTo(x(0.5), base - height * 0.7)
      ..lineTo(x(0.58), base - height * 0.64)
      ..lineTo(x(0.66), base - height * 0.4)
      // Monument spire on the right.
      ..lineTo(x(0.8), base - height * 0.32)
      ..lineTo(x(0.88), base - height * 0.32)
      ..lineTo(x(0.9), base - height * 1.0)
      ..lineTo(x(0.92), base - height * 0.32)
      ..lineTo(width, base - height * 0.28)
      ..lineTo(width, base)
      ..close();
    canvas.drawPath(
      path,
      Paint()..color = const Color(0xFF0B1426).withValues(alpha: 0.92),
    );
    // A few lit windows on the castle.
    final window = Paint()
      ..color = const Color(0xFFFFC857).withValues(alpha: 0.85);
    final windowSize = math.max(1.5, unit * 0.012);
    for (final spot in const [
      Offset(0.355, 0.72),
      Offset(0.385, 0.8),
      Offset(0.48, 0.85),
      Offset(0.43, 0.68),
      Offset(0.54, 0.58),
    ]) {
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x(spot.dx), base - height * (spot.dy * 0.9 - 0.1)),
          width: windowSize,
          height: windowSize * 1.4,
        ),
        window,
      );
    }
  }

  void _paintHalloween(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    _paintBats(canvas, size);

    // Jack-o'-lanterns dangling from the top edge on swaying strings.
    const lanterns = [
      (x: 0.92, string: 0.22, radius: 0.15, phase: 0.0),
      (x: 0.8, string: 0.08, radius: 0.1, phase: 0.3),
      (x: 0.69, string: 0.3, radius: 0.13, phase: 0.6),
    ];
    for (final lantern in lanterns) {
      final radius = unit * lantern.radius;
      final stringLength = unit * lantern.string;
      final sway = 0.1 * math.sin((progress + lantern.phase) * _twoPi);
      canvas
        ..save()
        ..translate(lantern.x * size.width, 0)
        ..rotate(sway)
        ..drawLine(
          Offset.zero,
          Offset(0, stringLength),
          Paint()
            ..color = const Color(0xFF6B6B7A)
            ..strokeWidth = math.max(1, unit * 0.006),
        )
        ..translate(0, stringLength + radius * 0.85);
      _drawPumpkin(
        canvas,
        radius,
        body: const Color(0xFF16110E),
        rib: const Color(0xFF3A2A1C),
        face: const Color(0xFFFFB02E),
        stem: const Color(0xFF2F3F1E),
      );
      canvas.restore();
    }
  }

  void _paintBats(Canvas canvas, Size size) {
    final unit = size.shortestSide;
    // Crescent moon with a small cluster of bats in its hollow, bottom-left.
    // Tall, narrow footers (mobile) shrink the moon to the available width.
    final radius = math.min(unit * 0.34, size.width * 0.14);
    final center = Offset(radius * 1.35, size.height - radius * 1.05);
    final moon = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
      Path()..addOval(
        Rect.fromCircle(
          center: center + Offset(radius * 0.42, -radius * 0.2),
          radius: radius * 0.82,
        ),
      ),
    );
    canvas
      ..drawPath(moon, Paint()..color = const Color(0xFFF6D766))
      ..save()
      ..clipPath(moon)
      ..drawOval(
        Rect.fromCenter(
          center: center + Offset(radius * 0.1, radius * 1.05),
          width: radius * 2.6,
          height: radius * 1.2,
        ),
        Paint()..color = const Color(0xFFE9BD40),
      )
      ..restore()
      ..save()
      ..translate(center.dx - radius * 0.5, center.dy - radius * 0.45)
      ..rotate(-0.5)
      ..drawOval(
        Rect.fromCenter(
          center: Offset.zero,
          width: radius * 0.22,
          height: radius * 0.5,
        ),
        Paint()..color = Colors.white.withValues(alpha: 0.35),
      )
      ..restore();

    final sparkle = center + Offset(-radius * 0.55, radius * 0.1);
    final arm = radius * 0.13;
    final waist = arm * 0.25;
    canvas.drawPath(
      Path()
        ..moveTo(sparkle.dx, sparkle.dy - arm)
        ..lineTo(sparkle.dx + waist, sparkle.dy - waist)
        ..lineTo(sparkle.dx + arm, sparkle.dy)
        ..lineTo(sparkle.dx + waist, sparkle.dy + waist)
        ..lineTo(sparkle.dx, sparkle.dy + arm)
        ..lineTo(sparkle.dx - waist, sparkle.dy + waist)
        ..lineTo(sparkle.dx - arm, sparkle.dy)
        ..lineTo(sparkle.dx - waist, sparkle.dy - waist)
        ..close(),
      Paint()..color = Colors.white.withValues(alpha: 0.95),
    );

    // Offsets are relative to the moon centre, in units of its radius.
    const bats = [
      (x: 0.7, y: 0.2, scale: 0.55, tilt: 0.0),
      (x: 1.05, y: -0.75, scale: 0.28, tilt: 0.15),
      (x: 0.3, y: -0.8, scale: 0.2, tilt: -0.2),
    ];
    final batPaint = Paint()..color = const Color(0xFF55555C);
    final wingShine = Paint()..color = Colors.white.withValues(alpha: 0.18);
    for (final bat in bats) {
      final scale = radius * bat.scale * 2 / 100;
      canvas
        ..save()
        ..translate(center.dx + bat.x * radius, center.dy + bat.y * radius)
        ..rotate(bat.tilt)
        ..scale(scale);
      for (final side in const [1.0, -1.0]) {
        canvas
          ..save()
          ..scale(side, 1)
          ..drawPath(_batHalf, batPaint)
          ..drawOval(
            Rect.fromCenter(
              center: const Offset(20, -13),
              width: 14,
              height: 4,
            ),
            wingShine,
          )
          ..restore();
      }
      canvas.restore();
    }
  }

  // Right half of a bat; mirrored to form the whole silhouette.
  static final Path _batHalf = Path()
    ..moveTo(0, -10)
    ..lineTo(4, -18)
    ..lineTo(7, -9)
    ..quadraticBezierTo(28, -14, 50, -24)
    ..quadraticBezierTo(44, -8, 37, 2)
    ..quadraticBezierTo(32, -2, 26, 6)
    ..quadraticBezierTo(20, 1, 12, 10)
    ..quadraticBezierTo(8, 18, 0, 14)
    ..close();

  void _drawPumpkin(
    Canvas canvas,
    double radius, {
    required Color body,
    required Color rib,
    required Color face,
    required Color stem,
  }) {
    final height = radius * 0.85;
    final bodyPaint = Paint()..color = body;
    final ribPaint = Paint()
      ..color = rib
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.05;
    for (final offset in const [-0.45, 0.45]) {
      final lobe = Rect.fromCenter(
        center: Offset(radius * offset, 0),
        width: radius * 1.1,
        height: height * 1.9,
      );
      canvas
        ..drawOval(lobe, bodyPaint)
        ..drawOval(lobe, ribPaint);
    }
    final middle = Rect.fromCenter(
      center: Offset.zero,
      width: radius * 1.25,
      height: height * 2.05,
    );
    canvas
      ..drawOval(middle, bodyPaint)
      ..drawOval(middle, ribPaint)
      ..drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            -radius * 0.07,
            -height - radius * 0.22,
            radius * 0.16,
            radius * 0.3,
          ),
          Radius.circular(radius * 0.05),
        ),
        Paint()..color = stem,
      );

    Path polygon(List<Offset> points) {
      final path = Path()
        ..moveTo(points.first.dx * radius, points.first.dy * radius);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx * radius, point.dy * radius);
      }
      return path..close();
    }

    final facePaint = Paint()..color = face;
    canvas
      ..drawPath(
        polygon(const [
          Offset(-0.58, -0.2),
          Offset(-0.2, -0.32),
          Offset(-0.3, 0),
        ]),
        facePaint,
      )
      ..drawPath(
        polygon(const [Offset(0.58, -0.2), Offset(0.2, -0.32), Offset(0.3, 0)]),
        facePaint,
      )
      ..drawPath(
        polygon(const [
          Offset(0, 0.02),
          Offset(-0.08, 0.16),
          Offset(0.08, 0.16),
        ]),
        facePaint,
      )
      ..drawPath(
        polygon(const [
          Offset(-0.5, 0.25),
          Offset(-0.33, 0.4),
          Offset(-0.17, 0.28),
          Offset(0, 0.42),
          Offset(0.17, 0.28),
          Offset(0.33, 0.4),
          Offset(0.5, 0.25),
          Offset(0.4, 0.5),
          Offset(0.2, 0.58),
          Offset(0, 0.52),
          Offset(-0.2, 0.58),
          Offset(-0.4, 0.5),
        ]),
        facePaint,
      );
  }

  void _paintAndean(Canvas canvas, Size size, double progress) {
    final unit = size.shortestSide;
    _paintRidge(canvas, size, progress, 0.45, 3, const Color(0xFF6D4C41), 0.22);
    _paintRidge(canvas, size, progress, 0.3, 5, const Color(0xFF8D6E63), 0.28);

    // Woven band of stepped diamonds that slowly scrolls sideways.
    final bandHeight = unit * 0.13;
    final top = size.height - bandHeight;
    canvas.drawRect(
      Rect.fromLTWH(0, top, size.width, bandHeight),
      Paint()..color = const Color(0xFF8E3B2F).withValues(alpha: 0.75),
    );
    final stripe = Paint()
      ..color = const Color(0xFFF2E3C6).withValues(alpha: 0.8);
    final stripeHeight = bandHeight * 0.07;
    canvas.drawRect(Rect.fromLTWH(0, top, size.width, stripeHeight), stripe);
    canvas.drawRect(
      Rect.fromLTWH(0, size.height - stripeHeight, size.width, stripeHeight),
      stripe,
    );

    const colors = [Color(0xFFE0A63A), Color(0xFF2A8C82), Color(0xFFF2E3C6)];
    const rows = [1, 3, 5, 3, 1];
    final tile = bandHeight * 0.8;
    final cell = tile / rows.length;
    final tileTop = top + (bandHeight - tile) / 2;
    final shift = -progress * tile * 2;
    final tiles = (size.width / tile).ceil() + 3;
    for (var index = 0; index < tiles; index++) {
      final left = shift + (index - 1) * tile;
      final paint = Paint()..color = colors[index % 2].withValues(alpha: 0.85);
      final centerPaint = Paint()..color = colors[2].withValues(alpha: 0.9);
      for (var row = 0; row < rows.length; row++) {
        final width = rows[row] * cell;
        final rect = Rect.fromLTWH(
          left + (tile - width) / 2,
          tileTop + row * cell,
          width,
          cell,
        );
        canvas.drawRect(rect, row == 2 ? centerPaint : paint);
      }
      // Dark gap keeps neighbouring diamonds visually separate.
      canvas.drawRect(
        Rect.fromLTWH(left + (tile - cell) / 2, tileTop + 2 * cell, cell, cell),
        Paint()..color = const Color(0xFF8E3B2F).withValues(alpha: 0.9),
      );
    }
  }

  void _paintRidge(
    Canvas canvas,
    Size size,
    double progress,
    double height,
    int peaks,
    Color color,
    double alpha,
  ) {
    final path = Path()..moveTo(0, size.height);
    const step = 6.0;
    for (var x = 0.0; x <= size.width + step; x += step) {
      final along = x / size.width;
      final ridge =
          0.5 +
          0.3 * math.sin(along * peaks * _twoPi) +
          0.2 * math.sin(along * peaks * 2.6 * _twoPi + 1.3);
      path.lineTo(x, size.height - size.height * height * ridge);
    }
    path
      ..lineTo(size.width + step, size.height)
      ..close();
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: alpha));
  }

  void _paintGlyphs(
    Canvas canvas,
    Size size,
    double progress,
    List<String> glyphs,
  ) {
    // Rectangular mode spreads the three glyphs across the whole area, tilted;
    // circular mode keeps them around the disc.
    final anchors = rectangular
        ? const [Offset(0.05, 0.8), Offset(0.62, 0.45), Offset(0.93, 0.22)]
        : const [Offset(0.12, 0.2), Offset(0.88, 0.75), Offset(0.85, 0.15)];
    const tilts = [-0.35, 0.3, -0.25];
    final baseSize = size.shortestSide * (rectangular ? 0.3 : 0.12);
    for (
      var index = 0;
      index < math.min(anchors.length, glyphs.length);
      index++
    ) {
      final bob = math.sin((progress + index / anchors.length) * _twoPi);
      final anchor = anchors[index];
      final painter = TextPainter(
        text: TextSpan(
          text: glyphs[index % glyphs.length],
          style: TextStyle(fontSize: baseSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      // Keep the whole (tilted) glyph inside the area so it is never cut off.
      final margin = baseSize * 0.8;
      canvas.translate(
        (anchor.dx * size.width).clamp(
          margin,
          math.max(margin, size.width - margin),
        ),
        (anchor.dy * size.height + bob * size.height * 0.02).clamp(
          margin,
          math.max(margin, size.height - margin),
        ),
      );
      if (rectangular) {
        canvas.rotate(tilts[index] + bob * 0.06);
      }
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _FestivePainter oldDelegate) =>
      oldDelegate.effect != effect ||
      oldDelegate.rectangular != rectangular ||
      oldDelegate.particles != particles;
}

enum _Shape { dot, petal, strip, blossomPetal, leaf }
