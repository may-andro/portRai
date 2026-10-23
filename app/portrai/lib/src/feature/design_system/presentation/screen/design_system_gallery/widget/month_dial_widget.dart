part of 'content_widget.dart';

/// A dot per month in that month's brand color, with the front card's dot
/// stretched. Tapping a dot deals its card; the arrows step through the deck.
class _MonthDialWidget extends StatelessWidget {
  const _MonthDialWidget({
    required this.deckPosition,
    required this.designSystems,
    required this.onDesignSystemClick,
    required this.onPreviousClick,
    required this.onNextClick,
  });

  final Animation<double> deckPosition;
  final List<DesignSystem> designSystems;
  final ValueChanged<DesignSystem> onDesignSystemClick;
  final VoidCallback onPreviousClick;
  final VoidCallback onNextClick;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final brightness = context.platformBrightness;
    return Row(
      children: [
        IconButton(
          tooltip: context.localizations.themeGalleryPrevious,
          onPressed: onPreviousClick,
          icon: DSIconWidget(
            Icons.chevron_left_rounded,
            color: palette.neutral.grey9,
            size: DSIconSize.medium,
          ),
        ),
        Expanded(
          child: AnimatedBuilder(
            animation: deckPosition,
            builder: (context, _) {
              final frontIndex =
                  deckPosition.value.round() % designSystems.length;
              return Row(
                children: [
                  for (final (index, designSystem) in designSystems.indexed)
                    Expanded(
                      child: _MonthDotWidget(
                        designSystem: designSystem,
                        color: DSTheme(
                          brightness: brightness,
                          designSystem: designSystem,
                        ).colorPalette.brand.primary,
                        isFront: index == frontIndex,
                        onClick: () => onDesignSystemClick(designSystem),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        IconButton(
          tooltip: context.localizations.themeGalleryNext,
          onPressed: onNextClick,
          icon: DSIconWidget(
            Icons.chevron_right_rounded,
            color: palette.neutral.grey9,
            size: DSIconSize.medium,
          ),
        ),
      ],
    );
  }
}

class _MonthDotWidget extends StatelessWidget {
  const _MonthDotWidget({
    required this.designSystem,
    required this.color,
    required this.isFront,
    required this.onClick,
  });

  final DesignSystem designSystem;
  final DSColor color;
  final bool isFront;
  final VoidCallback onClick;

  @override
  Widget build(BuildContext context) {
    final dotSize = context.space(factor: 1.25);
    return Semantics(
      button: true,
      selected: isFront,
      label: designSystem.title(context),
      child: InkResponse(
        onTap: onClick,
        child: SizedBox(
          height: context.space(factor: 5),
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              width: isFront ? dotSize * 2.4 : dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                color: color.color,
                borderRadius: BorderRadius.circular(dotSize),
                border: Border.all(
                  color: context.colorPalette.neutral.grey9.color.withValues(
                    alpha: isFront ? 0.8 : 0.2,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
