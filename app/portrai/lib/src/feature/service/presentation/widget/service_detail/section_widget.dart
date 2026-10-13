part of 'service_detail_widget.dart';

class _SectionWidget extends StatelessWidget {
  const _SectionWidget({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: [
        Row(
          spacing: context.space(),
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: context.colorPalette.accent.color,
                borderRadius: BorderRadius.circular(2),
              ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 1.5),
      children: steps.mapIndexed((index, step) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 1.5),
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor:
                  context.colorPalette.brand.primaryContainer.color,
              child: DSTextWidget(
                '${index + 1}',
                style: context.typography.emphasizedLabelMedium,
                color: context.colorPalette.brand.onPrimaryContainer,
              ),
            ),
            Expanded(
              child: DSTextWidget(
                step,
                style: context.typography.bodyMedium,
                color: context.colorPalette.neutral.grey9,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
