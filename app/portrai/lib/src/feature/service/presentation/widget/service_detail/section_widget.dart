part of 'service_detail_widget.dart';

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final accent = context.colorPalette.accent.color;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: [
        Row(
          spacing: context.space(),
          children: [
            Container(
              padding: EdgeInsets.all(context.space(factor: 0.75)),
              decoration: BoxDecoration(
                color: accent.withAlpha(36),
                borderRadius: BorderRadius.circular(
                  context.dimen.radiusLevel1.value,
                ),
              ),
              child: Icon(icon, size: 18, color: accent),
            ),
            DSTextWidget(
              title,
              style: context.typography.emphasizedTitleSmall,
              color: context.colorPalette.neutral.grey10,
            ),
          ],
        ),
        child,
      ],
    );
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
