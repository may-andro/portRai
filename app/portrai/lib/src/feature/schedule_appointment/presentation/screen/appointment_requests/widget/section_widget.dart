part of 'content_widget.dart';

/// A titled group of requests with their count, or [emptyChild] when it has
/// none.
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.count,
    required this.tone,
    required this.children,
    this.emptyChild,
  });

  final String title;
  final IconData icon;
  final int count;
  final _RequestTone tone;
  final List<Widget> children;
  final Widget? emptyChild;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 1.5),
      children: [
        Row(
          spacing: context.space(),
          children: [
            Container(
              padding: EdgeInsets.all(context.space(factor: 0.75)),
              decoration: BoxDecoration(
                color: tone.container.color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: tone.onContainer.color),
            ),
            Flexible(
              child: DSTextWidget(
                title,
                style: context.typography.emphasizedTitleLarge,
                color: palette.neutral.grey10,
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.space(),
                vertical: context.space(factor: 0.25),
              ),
              decoration: BoxDecoration(
                color: palette.surface.surfaceContainerHigh.color,
                borderRadius: BorderRadius.circular(999),
              ),
              child: DSTextWidget(
                '$count',
                style: context.typography.emphasizedLabelMedium,
                color: palette.neutral.grey8,
              ),
            ),
          ],
        ),
        if (children.isEmpty && emptyChild != null)
          emptyChild!
        else
          for (final (index, child) in children.indexed)
            child
                .animate()
                .fadeIn(duration: 300.ms, delay: (40 * index.clamp(0, 8)).ms)
                .slideY(begin: 0.06, curve: Curves.easeOutCubic),
      ],
    );
  }
}
