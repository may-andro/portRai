part of 'content_widget.dart';

/// A full-width band with an icon title, revealed when scrolled into view.
class _SectionWidget extends StatelessWidget {
  const _SectionWidget({
    required this.title,
    required this.icon,
    required this.child,
    this.isAlternate = false,
  });

  final String title;
  final IconData icon;
  final Widget child;
  final bool isAlternate;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final accent = palette.accent.color;
    final backgroundColor = isAlternate
        ? Color.alphaBlend(accent.withAlpha(22), palette.background.color)
        : palette.background.color;

    return JobOpeningRevealWidget(
      child: ColoredBox(
        color: backgroundColor,
        child: JobOpeningPageColumnWidget(
          verticalPadding: context.space(factor: context.isMobile ? 4 : 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 2.5),
            children: [
              Row(
                spacing: context.space(factor: 1.25),
                children: [
                  Container(
                    padding: EdgeInsets.all(context.space()),
                    decoration: BoxDecoration(
                      color: accent.withAlpha(36),
                      borderRadius: BorderRadius.circular(
                        context.dimen.radiusLevel1.value,
                      ),
                    ),
                    child: Icon(icon, size: 24, color: accent),
                  ),
                  Flexible(
                    child: DSTextWidget(
                      title,
                      style: context.isMobile
                          ? context.typography.emphasizedHeadlineSmall
                          : context.typography.emphasizedHeadlineMedium,
                      color: palette.neutral.grey10,
                    ),
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
