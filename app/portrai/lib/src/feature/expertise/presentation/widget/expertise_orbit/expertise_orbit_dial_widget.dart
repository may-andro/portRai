part of 'expertise_orbit_widget.dart';

/// Where the nodes sit on the dial: the top of a circle wider than the
/// section, turned so the node at a given position is at the top.
class _DialLayout {
  _DialLayout(this.width, this.count);

  /// How much larger the selected node is than the others.
  static const selectedScale = 1.5;

  final double width;
  final int count;

  double get nodeSize => (width * 0.16).clamp(56.0, 72.0);

  /// Radius of the circle the nodes sit on. Larger than half the width so
  /// only its top shows and the nodes keep their size on narrow screens.
  double get radius => width * 0.75;

  /// Angle between neighbouring nodes.
  double get step => nodeSize * 2 / radius;

  /// Angle from the top at which a node has fully left the section.
  double get edgeAngle => asin(min(1, (width / 2 + nodeSize / 2) / radius));

  /// Whether the dial turns past the last node to the first. Only when the
  /// node that moves to the other end does so out of sight.
  bool get isLooping => count * step / 2 > edgeAngle;

  /// Room above the selected node for its lift and shadow.
  double get top => nodeSize * 0.2;

  Offset get center =>
      Offset(width / 2, top + nodeSize * selectedScale / 2 + radius);

  double get height => center.dy - radius * cos(edgeAngle) + nodeSize * 0.6;

  /// Top of the space inside the ring, just under the selected node.
  double get innerTop => top + nodeSize * (selectedScale + 0.15);

  /// Side inset that keeps the inner space clear of the nodes lower down.
  double get innerInset => nodeSize * 0.75;

  /// Distance in nodes from [position] to the node at [index], the short way
  /// round when the dial loops.
  double offsetOf(int index, double position) {
    final distance = index - position;
    if (!isLooping) return distance;
    return (distance + count / 2) % count - count / 2;
  }

  /// Angle an arc keeps clear of a node's centre, room for the node and the
  /// arc's rounded cap.
  double clearanceOf({required bool isSelected}) {
    final halfSize = isSelected ? selectedScale / 2 : 0.5;
    return nodeSize * (halfSize + 0.08) / radius;
  }

  double angleOf(double offset) => -pi / 2 + offset * step;

  Offset nodeCenter(double offset) {
    final angle = angleOf(offset);
    return center + Offset(cos(angle), sin(angle)) * radius;
  }
}

/// The orbit for narrow screens: only the top of the ring shows, large
/// enough to tap, and turns when swiped. The selected expertise is described
/// inside the ring, above a button that opens it between arrows that turn
/// the dial.
class _OrbitDialWidget extends StatefulWidget {
  const _OrbitDialWidget({
    required this.expertises,
    required this.selection,
    required this.isVisible,
    required this.onClicked,
  });

  final List<ExpertiseEntity> expertises;
  final ValueNotifier<int> selection;
  final bool isVisible;
  final ValueChanged<ExpertiseEntity> onClicked;

  @override
  State<_OrbitDialWidget> createState() => _OrbitDialWidgetState();
}

class _OrbitDialWidgetState extends State<_OrbitDialWidget>
    with SingleTickerProviderStateMixin {
  /// The node at the top, in nodes. Fractional while turning.
  late final AnimationController _position = AnimationController.unbounded(
    vsync: this,
    value: min(widget.selection.value, _count - 1).toDouble(),
  )..addListener(_onPositionChanged);

  /// Starts the hint that the dial turns, shortly after it first shows.
  Timer? _nudgeTimer;
  bool _hasNudged = false;

  int get _count => widget.expertises.length;

  @override
  void initState() {
    super.initState();
    if (widget.isVisible) _scheduleNudge();
  }

  @override
  void didUpdateWidget(_OrbitDialWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !oldWidget.isVisible) _scheduleNudge();
  }

  @override
  void dispose() {
    _nudgeTimer?.cancel();
    _position.dispose();
    super.dispose();
  }

  /// Swings the dial a little way and lets it spring back, once, to show
  /// that it turns.
  void _scheduleNudge() {
    if (_hasNudged || _count < 2) return;
    _hasNudged = true;
    _nudgeTimer = Timer(900.ms, () {
      if (!mounted || _position.isAnimating) return;
      if (MediaQuery.disableAnimationsOf(context)) return;
      final isAtEnd = _position.value.round() >= _count - 1;
      _position.animateWith(
        SpringSimulation(
          const SpringDescription(mass: 1, stiffness: 60, damping: 9),
          _position.value,
          _position.value,
          isAtEnd ? -5.3 : 5.3,
        ),
      );
    });
  }

  void _onPositionChanged() {
    final index = _position.value.round() % _count;
    if (index != widget.selection.value) widget.selection.value = index;
  }

  void _onDragStart(DragStartDetails details) {
    _nudgeTimer?.cancel();
  }

  void _onDragUpdate(DragUpdateDetails details, _DialLayout layout) {
    final turned =
        _position.value -
        (details.primaryDelta ?? 0) / (layout.radius * layout.step);
    _position.value = layout.isLooping
        ? turned
        : turned.clamp(-0.4, _count - 0.6);
  }

  void _onDragEnd(DragEndDetails details, _DialLayout layout) {
    // A flick carries the dial on by a share of its speed.
    final flick =
        (details.primaryVelocity ?? 0) / (layout.radius * layout.step) * 0.15;
    _turnTo((_position.value - flick).round(), layout);
  }

  void _turnBy(int steps, _DialLayout layout) {
    _nudgeTimer?.cancel();
    _turnTo(_position.value.round() + steps, layout);
  }

  void _turnTo(int target, _DialLayout layout) {
    final bounded = layout.isLooping ? target : target.clamp(0, _count - 1);
    _position.animateTo(
      bounded.toDouble(),
      duration: 350.ms,
      curve: Curves.easeOutCubic,
    );
  }

  void _onNodeTap(int index, _DialLayout layout) {
    if (index == widget.selection.value) {
      _open(index);
      return;
    }
    final target = _position.value + layout.offsetOf(index, _position.value);
    _turnTo(target.round(), layout);
  }

  void _open(int index) => widget.onClicked(widget.expertises[index]);

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.brand.primary.color;

    return LayoutBuilder(
          builder: (context, constraints) {
            final layout = _DialLayout(constraints.maxWidth, _count);
            return ValueListenableBuilder<int>(
              valueListenable: widget.selection,
              builder: (context, index, _) {
                final selected = min(index, _count - 1);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: context.space(factor: 2),
                  children: [
                    Stack(
                      children: [
                        Positioned.fill(
                          child: DSOffscreenPauseWidget(
                            child: _OrbitSpinnerWidget(
                              painterOf: (turns) => _DialSpinnerPainter(
                                layout: layout,
                                color: accent,
                                turns: turns,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: layout.height,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onHorizontalDragStart: _onDragStart,
                            onHorizontalDragUpdate: (details) =>
                                _onDragUpdate(details, layout),
                            onHorizontalDragEnd: (details) =>
                                _onDragEnd(details, layout),
                            child: AnimatedBuilder(
                              animation: _position,
                              builder: (context, _) => _dial(layout, accent),
                            ),
                          ),
                        ),
                        // Inside the ring, so swipes reach the dial through it.
                        IgnorePointer(
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: layout.innerTop,
                              left: layout.innerInset,
                              right: layout.innerInset,
                            ),
                            child: _details(selected, accent),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: context.screenHorizontalPadding,
                      child: _controls(context, layout, selected),
                    ),
                  ],
                );
              },
            );
          },
        )
        .animate(target: widget.isVisible ? 1 : 0)
        .slideY(begin: 0.1, duration: 500.ms, curve: Curves.easeOutCubic)
        .fadeIn(duration: 400.ms);
  }

  Widget _dial(_DialLayout layout, Color accent) {
    final position = _position.value;
    final selected = position.round() % _count;
    // Nearest last, so the selected node is drawn over its neighbours.
    final offsets = {
      for (var index = 0; index < _count; index++)
        index: layout.offsetOf(index, position),
    };
    final visible =
        offsets.keys
            .where(
              (index) =>
                  offsets[index]!.abs() * layout.step <= layout.edgeAngle,
            )
            .toList()
          ..sort(
            (first, second) =>
                offsets[second]!.abs().compareTo(offsets[first]!.abs()),
          );

    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DialPainter(
              layout: layout,
              color: accent,
              position: position,
              selected: selected,
            ),
          ),
        ),
        for (final index in visible)
          _node(layout, index, offsets[index]!, selected, accent),
      ],
    );
  }

  Widget _node(
    _DialLayout layout,
    int index,
    double offset,
    int selected,
    Color accent,
  ) {
    final nodeCenter = layout.nodeCenter(offset);
    // Laid out at the selected size so its image stays sharp, and scaled
    // down when it isn't selected.
    final nodeSize = layout.nodeSize * _DialLayout.selectedScale;
    final expertise = widget.expertises[index];
    // Nodes fade as they turn towards the edges.
    final nearness = 1 - offset.abs() * layout.step / layout.edgeAngle;

    // Keyed, as the nodes are reordered while turning and each must keep
    // its own scale animation.
    return Positioned(
      key: ValueKey(index),
      left: nodeCenter.dx - nodeSize / 2,
      top: nodeCenter.dy - nodeSize / 2,
      width: nodeSize,
      height: nodeSize,
      child: Opacity(
        opacity: 0.35 + 0.65 * nearness.clamp(0.0, 1.0),
        child: Semantics(
          button: true,
          selected: index == selected,
          label: expertise.title,
          child: GestureDetector(
            onTap: () => _onNodeTap(index, layout),
            child: _OrbitNodeWidget(
              expertise: expertise,
              isSelected: index == selected,
              size: nodeSize,
              accent: accent,
              selectedScale: 1,
              restingScale: 1 / _DialLayout.selectedScale,
            ),
          ),
        ),
      ),
    );
  }

  Widget _details(int selected, Color accent) {
    // Full width, so each line is centred in the same place for every
    // expertise rather than following the width of its longest line.
    return SizedBox(
      width: double.infinity,
      child: AnimatedSwitcher(
        duration: 250.ms,
        layoutBuilder: (current, previous) => Stack(
          alignment: Alignment.topCenter,
          children: [...previous, ?current],
        ),
        child: _DialSummaryWidget(
          key: ValueKey(selected),
          expertise: widget.expertises[selected],
          position: selected + 1,
          count: _count,
          accent: accent,
        ),
      ),
    );
  }

  /// The button that opens the selected expertise between arrows that turn
  /// the dial.
  Widget _controls(BuildContext context, _DialLayout layout, int selected) {
    final palette = context.colorPalette;
    final buttonColor = _dsColor(
      Color.alphaBlend(
        palette.surface.onInverseSurface.color.withAlpha(18),
        palette.surface.inverseSurface.color,
      ),
    );
    final canTurnBack = layout.isLooping || selected > 0;
    final canTurnOn = layout.isLooping || selected < _count - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: context.space(factor: 4),
      children: [
        Tooltip(
          message: context.localizations.expertisePrevious,
          child: DSIconButtonWidget(
            Icons.chevron_left_rounded,
            iconColor: palette.surface.onInverseSurface,
            buttonColor: buttonColor,
            size: DSIconButtonSize.medium,
            onPressed: canTurnBack ? () => _turnBy(-1, layout) : null,
          ),
        ),
        Tooltip(
          message: context.localizations.expertiseViewDetails,
          child: DSIconButtonWidget(
            Icons.arrow_outward_rounded,
            iconColor: palette.brand.onPrimary,
            buttonColor: palette.brand.primary,
            size: DSIconButtonSize.large,
            onPressed: () => _open(selected),
          ),
        ),
        Tooltip(
          message: context.localizations.expertiseNext,
          child: DSIconButtonWidget(
            Icons.chevron_right_rounded,
            iconColor: palette.surface.onInverseSurface,
            buttonColor: buttonColor,
            size: DSIconButtonSize.medium,
            onPressed: canTurnOn ? () => _turnBy(1, layout) : null,
          ),
        ),
      ],
    );
  }
}

/// The selected expertise inside the dial's ring: where it is in the list,
/// its name and its first skills. The name always takes two lines' height so
/// the dial is the same size for every expertise.
class _DialSummaryWidget extends StatelessWidget {
  const _DialSummaryWidget({
    super.key,
    required this.expertise,
    required this.position,
    required this.count,
    required this.accent,
  });

  static const _titleLines = 2;
  static const _shownSkills = 3;

  final ExpertiseEntity expertise;

  /// Where [expertise] is in the list, from 1.
  final int position;
  final int count;
  final Color accent;

  String _padded(int number) => number.toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    final foreground = context.colorPalette.surface.onInverseSurface;
    final titleStyle = context.typography.emphasizedTitleLarge;
    final skills = expertise.skills;
    final hiddenSkills = skills.length - _shownSkills;
    final skillsLine = [
      skills.take(_shownSkills).map((skill) => skill.name).join(' · '),
      if (hiddenSkills > 0) '+$hiddenSkills',
    ].join('  ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: context.space() / 2,
      children: [
        DSTextWidget(
          '${_padded(position)} / ${_padded(count)}',
          style: context.typography.emphasizedLabelMedium,
          color: _dsColor(accent),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            // Invisible blank lines in the same style hold the height.
            ExcludeSemantics(
              child: Opacity(
                opacity: 0,
                child: DSTextWidget(
                  List.filled(_titleLines, ' ').join('\n'),
                  style: titleStyle,
                  color: foreground,
                  maxLines: _titleLines,
                ),
              ),
            ),
            DSTextWidget(
              expertise.title,
              style: titleStyle,
              color: foreground,
              textAlign: TextAlign.center,
              maxLines: _titleLines,
              textOverflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        DSTextWidget(
          skillsLine,
          style: context.typography.bodySmall,
          color: _dsColor(foreground.color.withAlpha(170)),
          textAlign: TextAlign.center,
          maxLines: 1,
          textOverflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// A dotted ring just outside the dial's nodes, slowly turning, and a small
/// satellite sweeping along the part of the node ring that shows.
class _DialSpinnerPainter extends CustomPainter {
  const _DialSpinnerPainter({
    required this.layout,
    required this.color,
    required this.turns,
  });

  /// Satellite sweeps across the dial in each loop.
  static const _sweeps = 8;

  final _DialLayout layout;
  final Color color;

  /// Progress of one full 40 second loop, from 0 to 1.
  final double turns;

  @override
  void paint(Canvas canvas, Size size) {
    _dots(canvas);
    _satellite(canvas);
  }

  void _dots(Canvas canvas) {
    final radius = layout.radius + layout.nodeSize * 0.85;
    final count = (2 * pi / (layout.step / 4)).round();
    final paint = Paint()..color = color.withAlpha(80);
    final start = -turns * 2 * pi;

    for (var dotIndex = 0; dotIndex < count; dotIndex++) {
      final angle = start + 2 * pi * dotIndex / count;
      canvas.drawCircle(
        layout.center + Offset(cos(angle), sin(angle)) * radius,
        1.5,
        paint,
      );
    }
  }

  void _satellite(Canvas canvas) {
    final sweep = 2 * layout.edgeAngle;
    final head = -pi / 2 - layout.edgeAngle + (turns * _sweeps % 1) * sweep;
    const trail = 10;
    for (var step = 0; step < trail; step++) {
      final angle = head - step * 0.04;
      final fade = 1 - step / trail;
      canvas.drawCircle(
        layout.center + Offset(cos(angle), sin(angle)) * layout.radius,
        layout.nodeSize * 0.05 * fade + 1,
        Paint()..color = color.withAlpha((230 * fade).round()),
      );
    }
  }

  @override
  bool shouldRepaint(_DialSpinnerPainter oldDelegate) {
    return turns != oldDelegate.turns ||
        color != oldDelegate.color ||
        layout.width != oldDelegate.layout.width ||
        layout.count != oldDelegate.layout.count;
  }
}

/// The dial's ring and the arcs between its nodes, turned with the dial.
class _DialPainter extends CustomPainter {
  const _DialPainter({
    required this.layout,
    required this.color,
    required this.position,
    required this.selected,
  });

  final _DialLayout layout;
  final Color color;
  final double position;
  final int selected;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      layout.center,
      layout.radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withAlpha(40),
    );
    _arcs(canvas);
  }

  void _arcs(Canvas canvas) {
    final count = layout.count;
    final rect = Rect.fromCircle(center: layout.center, radius: layout.radius);
    if (count < 2) return;

    for (var index = 0; index < count; index++) {
      if (!layout.isLooping && index == count - 1) continue;
      final next = (index + 1) % count;
      final isLit = index == selected || next == selected;
      final startClearance = layout.clearanceOf(isSelected: index == selected);
      final sweep =
          layout.step -
          startClearance -
          layout.clearanceOf(isSelected: next == selected);
      if (sweep <= 0) continue;
      final start =
          layout.angleOf(layout.offsetOf(index, position)) + startClearance;

      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = isLit ? 4 : 2.5
        ..color = color.withAlpha(isLit ? 255 : 80);

      if (isLit) {
        canvas.drawArc(
          rect,
          start,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round
            ..strokeWidth = paint.strokeWidth * 3
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
            ..color = color.withAlpha(120),
        );
      }
      canvas.drawArc(rect, start, sweep, false, paint);
    }
  }

  @override
  bool shouldRepaint(_DialPainter oldDelegate) {
    return position != oldDelegate.position ||
        selected != oldDelegate.selected ||
        color != oldDelegate.color ||
        layout.width != oldDelegate.layout.width ||
        layout.count != oldDelegate.layout.count;
  }
}
