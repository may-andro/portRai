part of 'content_widget.dart';

/// Closes the page with the job board attribution and a second Apply.
class _ApplyBandWidget extends StatelessWidget {
  const _ApplyBandWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final background = palette.surface.inverseSurface.color;
    final gradientEnd = Color.alphaBlend(
      palette.accent.color.withAlpha(80),
      background,
    );

    final copy = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(),
      children: [
        DSTextWidget(
          localizations.jobOpeningApplyTitle,
          style: context.typography.emphasizedHeadlineSmall,
          color: palette.surface.onInverseSurface,
        ),
        DSTextWidget(
          localizations.jobOpeningApplyDescription(jobOpening.sourceName),
          style: context.typography.bodyLarge,
          color: palette.surface.onInverseSurface,
        ),
      ],
    );
    final applyButton = DSButtonWidget(
      label: localizations.jobOpeningApply(jobOpening.sourceName),
      icon: Icons.arrow_outward_rounded,
      iconDirection: DSButtonIconDirection.right,
      isExpanded: false,
      onPressed: () => context.bloc.add(const ApplyClickEvent()),
    );

    return JobOpeningRevealWidget(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            end: Alignment.bottomRight,
            colors: [background, gradientEnd],
          ),
        ),
        child: SafeArea(
          top: false,
          child: JobOpeningPageColumnWidget(
            verticalPadding: context.space(factor: 6),
            child: context.isMobile
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: context.space(factor: 3),
                    children: [copy, applyButton],
                  )
                : Row(
                    spacing: context.space(factor: 3),
                    children: [
                      Expanded(child: copy),
                      applyButton,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
