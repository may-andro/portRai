part of 'content_widget.dart';

/// Key numbers of the expertise, counted up when the band scrolls into view.
class _StatsBandWidget extends StatelessWidget {
  const _StatsBandWidget({required this.expertise});

  final ExpertiseEntity expertise;

  @override
  Widget build(BuildContext context) {
    final localizations = context.localizations;
    final maxYears = expertise.maxYears;
    final latestYear = expertise.latestYearUsed;
    final expertCount = expertise.expertSkillCount;

    final stats = [
      _StatWidget(
        icon: Icons.bolt_rounded,
        value: expertise.skills.length,
        label: localizations.expertiseStatSkills,
      ),
      if (expertCount > 0)
        _StatWidget(
          icon: Icons.workspace_premium_rounded,
          value: expertCount,
          label: localizations.expertiseStatExpert,
        ),
      if (maxYears != null)
        _StatWidget(
          icon: Icons.history_rounded,
          value: maxYears,
          label: localizations.expertiseStatYears,
        ),
      if (latestYear != null)
        _StatWidget(
          icon: Icons.event_available_rounded,
          value: latestYear,
          label: localizations.expertiseStatLastUsed,
          countUp: false,
        ),
    ];

    final statsWrap = Wrap(
      spacing: context.space(factor: 5),
      runSpacing: context.space(factor: 4),
      children: stats,
    );
    final chart = _StatsChartWidget(expertise: expertise);

    return _BandWidget(
      verticalFactor: context.isDesktop ? 6 : 4,
      color: Color.alphaBlend(
        context.colorPalette.brand.primary.color.withAlpha(36),
        context.colorPalette.surface.surface.color,
      ),
      child: context.isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: context.space(factor: 3),
              children: [statsWrap, chart],
            )
          : Row(
              spacing: context.space(factor: 6),
              children: [
                Expanded(child: statsWrap),
                Expanded(child: chart),
              ],
            ),
    );
  }
}

/// Bar chart animation drawn from the skills' years of experience.
class _StatsChartWidget extends StatefulWidget {
  const _StatsChartWidget({required this.expertise});

  final ExpertiseEntity expertise;

  @override
  State<_StatsChartWidget> createState() => _StatsChartWidgetState();
}

class _StatsChartWidgetState extends State<_StatsChartWidget> {
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

    return DSLottieDataWidget(data: _animation!);
  }
}

class _StatWidget extends StatefulWidget {
  const _StatWidget({
    required this.icon,
    required this.value,
    required this.label,
    this.countUp = true,
  });

  final IconData icon;
  final int value;
  final String label;
  final bool countUp;

  @override
  State<_StatWidget> createState() => _StatWidgetState();
}

class _StatWidgetState extends State<_StatWidget> {
  bool _hovering = false;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final valueStyle = context.typography.emphasizedHeadlineMedium;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovering = true),
      onExit: (_) => setState(() => _hovering = false),
      child: AnimatedScale(
        scale: _hovering ? 1.05 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 1.5),
          children: [
            Icon(widget.icon, size: 40, color: palette.brand.primary.color),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.countUp)
                  TweenAnimationBuilder<int>(
                    tween: IntTween(begin: 0, end: widget.value),
                    duration: const Duration(milliseconds: 1200),
                    curve: Curves.easeOutCubic,
                    builder: (context, count, _) {
                      return DSTextWidget(
                        '$count',
                        style: valueStyle,
                        color: palette.neutral.grey10,
                      );
                    },
                  )
                else
                  DSTextWidget(
                    '${widget.value}',
                    style: valueStyle,
                    color: palette.neutral.grey10,
                  ),
                DSTextWidget(
                  widget.label.toUpperCase(),
                  style: context.typography.emphasizedLabelMedium,
                  color: palette.neutral.grey7,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
