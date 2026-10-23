part of 'expertise_orbit_widget.dart';

class _OrbitRingWidget extends StatelessWidget {
  const _OrbitRingWidget({
    required this.expertises,
    required this.selected,
    required this.onSelect,
    required this.isVisible,
  });

  final List<ExpertiseEntity> expertises;
  final int selected;
  final ValueChanged<int> onSelect;
  final bool isVisible;

  void _selectAt(_OrbitLayout layout, Offset position) {
    final index = layout.indexAt(position);
    if (index != null) onSelect(index);
  }

  // A pointer has already selected the node by hovering, a touch selects it
  // with the first tap and opens it with the next.
  void _openAt(BuildContext context, _OrbitLayout layout, Offset position) {
    final index = layout.indexAt(position);
    if (index == null) return;
    if (index == selected) {
      ExpertiseScreen.navigate(context, expertise: expertises[index]);
    } else {
      onSelect(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.brand.primary.color;

    return LayoutBuilder(
      builder: (context, constraints) {
        final side = min(constraints.maxWidth, constraints.maxHeight);
        final layout = _OrbitLayout(side, expertises.length);

        return MouseRegion(
              onHover: (event) => _selectAt(layout, event.localPosition),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) =>
                    _openAt(context, layout, details.localPosition),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _OrbitSpinnerWidget(
                      size: Size.square(layout.side),
                      painterOf: (turns) => _OrbitSpinnerPainter(
                        layout: layout,
                        color: accent,
                        turns: turns,
                      ),
                    ),
                    Positioned.fill(
                      child: TweenAnimationBuilder<double>(
                        key: ValueKey(selected),
                        tween: Tween(begin: 0, end: 1),
                        duration: 350.ms,
                        curve: Curves.easeOutCubic,
                        builder: (context, progress, _) {
                          return CustomPaint(
                            painter: _OrbitArcsPainter(
                              layout: layout,
                              color: accent,
                              selected: selected,
                              progress: progress,
                            ),
                          );
                        },
                      ),
                    ),
                    for (var index = 0; index < expertises.length; index++)
                      _node(context, layout, index, accent),
                    _center(context, layout, accent),
                  ],
                ),
              ),
            )
            .animate(target: isVisible ? 1 : 0)
            .scale(
              begin: const Offset(0.7, 0.7),
              end: const Offset(1, 1),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
            .fadeIn(duration: 400.ms);
      },
    );
  }

  Widget _center(BuildContext context, _OrbitLayout layout, Color accent) {
    final diameter = 2 * (layout.radius - layout.nodeSize);

    return SizedBox.square(
      dimension: diameter,
      child: Padding(
        padding: EdgeInsets.all(diameter * 0.08),
        child: AnimatedSwitcher(
          duration: 250.ms,
          child: _OrbitSummaryWidget(
            key: ValueKey(selected),
            expertise: expertises[selected],
            accent: accent,
            onOpen: () => ExpertiseScreen.navigate(
              context,
              expertise: expertises[selected],
            ),
          ),
        ),
      ),
    );
  }

  Widget _node(
    BuildContext context,
    _OrbitLayout layout,
    int index,
    Color accent,
  ) {
    final offset = layout.nodeOffset(index);
    // Laid out at the selected size so its image stays sharp, and scaled
    // down when it isn't selected.
    final nodeSize = layout.nodeSize * _OrbitLayout.selectedScale;

    return Positioned(
      left: layout.center.dx + offset.dx - nodeSize / 2,
      top: layout.center.dy + offset.dy - nodeSize / 2,
      width: nodeSize,
      height: nodeSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: _OrbitNodeWidget(
          expertise: expertises[index],
          isSelected: index == selected,
          size: nodeSize,
          accent: accent,
          selectedScale: 1,
          restingScale: 1 / _OrbitLayout.selectedScale,
        ),
      ),
    );
  }
}
