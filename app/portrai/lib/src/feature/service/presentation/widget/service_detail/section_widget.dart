part of 'service_detail_widget.dart';

enum _SectionStyle { tinted, plain, dark, accentBar, outlined, neutral }

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.child,
    this.style = _SectionStyle.tinted,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final _SectionStyle style;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final radius = BorderRadius.circular(context.dimen.radiusLevel3.value);
    final padding = EdgeInsets.all(context.space(factor: 2));
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: [_buildTitle(context), child],
    );

    return switch (style) {
      _SectionStyle.tinted => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: accent.withAlpha(14),
          borderRadius: radius,
          border: Border.all(color: accent.withAlpha(60)),
        ),
        child: content,
      ),
      _SectionStyle.plain => Padding(
        padding: EdgeInsets.symmetric(vertical: context.space()),
        child: content,
      ),
      _SectionStyle.dark => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              palette.surface.inverseSurface.color,
              Color.lerp(
                palette.surface.inverseSurface.color,
                palette.brand.primary.color,
                0.3,
              )!,
            ],
          ),
        ),
        child: content,
      ),
      _SectionStyle.accentBar => ClipRRect(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: palette.neutral.grey9.color.withAlpha(10),
            border: Border(left: BorderSide(color: accent, width: 5)),
          ),
          padding: padding,
          child: content,
        ),
      ),
      _SectionStyle.outlined => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(
            context.dimen.radiusLevel3.value * 2,
          ),
          border: Border.all(color: accent, width: 1.5),
        ),
        child: content,
      ),
      _SectionStyle.neutral => Container(
        width: double.infinity,
        padding: padding,
        decoration: BoxDecoration(
          color: palette.neutral.grey9.color.withAlpha(14),
          borderRadius: radius,
        ),
        child: content,
      ),
    };
  }

  Widget _buildTitle(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final typography = context.typography;

    final badge = Container(
      padding: EdgeInsets.all(context.space(factor: 0.75)),
      decoration: BoxDecoration(
        color: accent.withAlpha(36),
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel1.value),
      ),
      child: Icon(icon, size: 18, color: accent),
    );

    return switch (style) {
      _SectionStyle.plain => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DSTextWidget(
            title,
            style: typography.emphasizedHeadlineSmall,
            color: palette.neutral.grey10,
          ),
        ],
      ),
      _SectionStyle.dark => Row(
        spacing: context.space(),
        children: [
          Icon(icon, size: 22, color: accent),
          DSTextWidget(
            title,
            style: typography.titleLarge,
            color: palette.surface.onInverseSurface,
          ),
        ],
      ),
      _SectionStyle.accentBar => DSTextWidget(
        title.toUpperCase(),
        style: typography.emphasizedLabelLarge,
        color: palette.accent,
      ),
      _SectionStyle.outlined => Row(
        spacing: context.space(),
        children: [
          badge,
          DSTextWidget(
            title,
            style: typography.titleMedium,
            color: palette.neutral.grey10,
            isItalic: true,
          ),
        ],
      ),
      _SectionStyle.neutral => Row(
        spacing: context.space(),
        children: [
          badge,
          DSTextWidget(
            title,
            style: typography.emphasizedTitleMedium,
            color: palette.neutral.grey10,
          ),
        ],
      ),
      _SectionStyle.tinted => Row(
        spacing: context.space(),
        children: [
          badge,
          DSTextWidget(
            title,
            style: typography.emphasizedTitleSmall,
            color: palette.neutral.grey10,
          ),
        ],
      ),
    };
  }
}

class _CheckListWidget extends StatelessWidget {
  const _CheckListWidget({required this.items, required this.icon});

  final List<String> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.accent.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.25),
      children: [
        for (final item in items)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 1.25),
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(icon, size: 18, color: accent),
              ),
              Expanded(
                child: DSTextWidget(
                  item,
                  style: context.typography.bodyMedium,
                  color: context.colorPalette.neutral.grey9,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _TagsWidget extends StatelessWidget {
  const _TagsWidget({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: 0.5),
      runSpacing: context.space(factor: 0.5),
      children: [for (final tag in tags) DSTagWidget(label: tag)],
    );
  }
}

class _StepsWidget extends StatelessWidget {
  const _StepsWidget({required this.steps});

  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.accent.color;

    return Column(
      children: steps.mapIndexed((index, step) {
        final isLast = index == steps.length - 1;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: context.space(factor: 1.5),
            children: [
              Column(
                children: [
                  CircleAvatar(
                    radius: 13,
                    backgroundColor: accent,
                    child: DSTextWidget(
                      '${index + 1}',
                      style: context.typography.emphasizedLabelMedium,
                      color: context.colorPalette.brand.onTertiary,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(width: 2, color: accent.withAlpha(70)),
                    ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: 3,
                    bottom: isLast ? 0 : context.space(factor: 2),
                  ),
                  child: DSTextWidget(
                    step,
                    style: context.typography.bodyMedium,
                    color: context.colorPalette.neutral.grey9,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
