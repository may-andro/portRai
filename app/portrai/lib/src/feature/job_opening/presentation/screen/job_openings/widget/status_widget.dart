part of 'content_widget.dart';

class _EmptyWidget extends StatelessWidget {
  const _EmptyWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 4)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Column(
        spacing: context.space(factor: 2),
        children: [
          DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.talentSearch,
            width: context.space(factor: 26),
          ),
          DSTextWidget(
            context.localizations.jobOpeningsEmpty,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms);
  }
}

/// Shown when the search and filters leave no openings.
class _NoResultsWidget extends StatelessWidget {
  const _NoResultsWidget();

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 4)),
      decoration: BoxDecoration(
        color: palette.surface.surfaceContainerLow.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel3.value),
        border: Border.all(color: palette.outline.outlineVariant.color),
      ),
      child: Column(
        spacing: context.space(factor: 1.5),
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 40,
            color: palette.neutral.grey7.color,
          ),
          DSTextWidget(
            context.localizations.jobOpeningsNoResults,
            style: context.typography.bodyLarge,
            color: palette.neutral.grey8,
            textAlign: TextAlign.center,
          ),
          DSButtonWidget(
            label: context.localizations.jobOpeningsClearFilters,
            icon: Icons.filter_alt_off_outlined,
            variant: DSButtonVariant.secondary,
            size: DSButtonSize.small,
            isExpanded: false,
            onPressed: () =>
                context.bloc.add(const JobOpeningsClearFiltersClickEvent()),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}
