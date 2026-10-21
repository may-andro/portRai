part of 'content_widget.dart';

class _ReasonsWidget extends StatelessWidget {
  const _ReasonsWidget({required this.reasons});

  final List<String> reasons;

  @override
  Widget build(BuildContext context) {
    final spacing = context.space(factor: 1.5);
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 760 ? 2 : 1;
        final cardWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final (reasonIndex, reason) in reasons.indexed)
              SizedBox(
                width: cardWidth,
                child: _ReasonCardWidget(
                  reason: reason,
                  number: reasonIndex + 1,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ReasonCardWidget extends StatelessWidget {
  const _ReasonCardWidget({required this.reason, required this.number});

  final String reason;
  final int number;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;

    return Container(
      padding: EdgeInsets.all(context.space(factor: 2)),
      decoration: BoxDecoration(
        color: palette.surface.surface.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        border: Border.all(color: accent.withAlpha(55)),
        boxShadow: [
          BoxShadow(
            color: accent.withAlpha(12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: context.space(factor: 1.5),
        children: [
          DSTextWidget(
            number.toString().padLeft(2, '0'),
            style: context.typography.emphasizedTitleLarge,
            color: palette.accent,
          ),
          Expanded(
            child: DSTextWidget(
              reason,
              style: context.typography.bodyLarge,
              color: palette.neutral.grey10,
            ),
          ),
        ],
      ),
    );
  }
}
