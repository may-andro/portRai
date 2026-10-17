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
                    _OrbitSpinnerWidget(layout: layout, color: accent),
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
    final palette = context.colorPalette;
    final expertise = expertises[selected];
    final diameter = 2 * (layout.radius - layout.nodeSize);
    final skillsLabel =
        '${expertise.skills.length} '
        '${context.localizations.expertiseStatSkills}';

    return SizedBox.square(
      dimension: diameter,
      child: Padding(
        padding: EdgeInsets.all(diameter * 0.08),
        child: AnimatedSwitcher(
          duration: 250.ms,
          child: Column(
            key: ValueKey(selected),
            mainAxisAlignment: MainAxisAlignment.center,
            spacing: context.space(),
            children: [
              Flexible(
                child: DSTextWidget(
                  expertise.title,
                  style: context.typography.emphasizedHeadlineSmall,
                  color: palette.surface.onInverseSurface,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  textOverflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: context.space(),
                  vertical: context.space() / 3,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  color: accent.withAlpha(36),
                  border: Border.all(color: accent.withAlpha(140)),
                ),
                child: DSTextWidget(
                  skillsLabel,
                  style: context.typography.labelSmall,
                  color: _dsColor(accent),
                ),
              ),
            ],
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
    final palette = context.colorPalette;
    final background = palette.surface.inverseSurface.color;
    final foreground = palette.surface.onInverseSurface.color;
    final offset = layout.nodeOffset(index);
    final isSelected = index == selected;
    final nodeSize = layout.nodeSize;
    final iconSize = nodeSize * 0.48;
    final iconColor = isSelected ? background : foreground;
    final title = expertises[index].title;

    return Positioned(
      left: layout.center.dx + offset.dx - nodeSize / 2,
      top: layout.center.dy + offset.dy - nodeSize / 2,
      width: nodeSize,
      height: nodeSize,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: AnimatedSlide(
          offset: isSelected ? const Offset(0, -0.08) : Offset.zero,
          duration: 220.ms,
          curve: Curves.easeOutBack,
          child: AnimatedScale(
            scale: isSelected ? 1.2 : 1,
            duration: 220.ms,
            curve: Curves.easeOutBack,
            child: AnimatedContainer(
              duration: 220.ms,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? accent
                    : Color.alphaBlend(foreground.withAlpha(18), background),
                border: Border.all(
                  color: isSelected ? accent : foreground.withAlpha(70),
                  width: 1.5,
                ),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: accent.withAlpha(120),
                      blurRadius: 22,
                      offset: Offset(0, nodeSize * 0.12),
                    )
                  else
                    BoxShadow(
                      color: Colors.black.withAlpha(60),
                      blurRadius: 8,
                      offset: Offset(0, nodeSize * 0.05),
                    ),
                ],
              ),
              child: title.toLowerCase().contains('flutter')
                  ? CustomPaint(
                      size: Size.square(iconSize),
                      painter: _FlutterLogoPainter(color: iconColor),
                    )
                  : Icon(_iconFor(title), size: iconSize, color: iconColor),
            ),
          ),
        ),
      ),
    );
  }
}

IconData _iconFor(String title) {
  final name = title.toLowerCase();
  const icons = <String, IconData>{
    'android': Icons.android,
    'ios': Icons.phone_iphone_rounded,
    'architecture': Icons.account_tree_outlined,
    'performance': Icons.speed_rounded,
    'backend': Icons.dns_outlined,
    'testing': Icons.bug_report_outlined,
    'release': Icons.rocket_launch_outlined,
    'deploy': Icons.rocket_launch_outlined,
    'ai': Icons.auto_awesome_rounded,
    'leadership': Icons.groups_outlined,
    'design': Icons.palette_outlined,
  };
  for (final entry in icons.entries) {
    if (name.contains(entry.key)) return entry.value;
  }
  return Icons.code_rounded;
}
