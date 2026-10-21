part of 'content_widget.dart';

class _HeroWidget extends StatelessWidget {
  const _HeroWidget({
    required this.jobOpening,
    required this.isTailoredCvAvailable,
  });

  final JobOpeningEntity jobOpening;
  final bool isTailoredCvAvailable;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isWide = !context.isMobile;
    final scoreSize = isWide ? 190.0 : 150.0;

    return ColoredBox(
      color: palette.background.color,
      child: PageChromeWidget(
        closeColor: palette.neutral.grey10.color,
        child: ClipRect(
          child: Stack(
            children: [
              const Positioned.fill(child: JobOpeningHeroBackgroundWidget()),
              JobOpeningPageColumnWidget(
                verticalPadding: context.space(factor: isWide ? 7 : 4),
                child: isWide
                    ? Row(
                        spacing: context.space(factor: 5),
                        children: [
                          Expanded(
                            child: _HeroCopyWidget(
                              jobOpening: jobOpening,
                              isTailoredCvAvailable: isTailoredCvAvailable,
                            ),
                          ),
                          _ScoreBadgeWidget(
                            score: jobOpening.score,
                            size: scoreSize,
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: context.space(factor: 3),
                        children: [
                          _ScoreBadgeWidget(
                            score: jobOpening.score,
                            size: scoreSize,
                          ),
                          _HeroCopyWidget(
                            jobOpening: jobOpening,
                            isTailoredCvAvailable: isTailoredCvAvailable,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCopyWidget extends StatelessWidget {
  const _HeroCopyWidget({
    required this.jobOpening,
    required this.isTailoredCvAvailable,
  });

  final JobOpeningEntity jobOpening;

  /// Shows a button that opens a CV tailored for the job next to Apply.
  final bool isTailoredCvAvailable;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');

    return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 1.5),
          children: [
            Container(
              width: context.space(factor: 5),
              height: 4,
              decoration: BoxDecoration(
                color: palette.accent.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            DSTextWidget(
              jobOpening.title,
              style: context.isMobile
                  ? context.typography.emphasizedHeadlineMedium
                  : context.typography.emphasizedDisplaySmall,
              color: palette.neutral.grey10,
            ),
            DSTextWidget(
              companyAndLocation,
              style: context.typography.titleLarge,
              color: palette.neutral.grey8,
            ),
            // The job boards ask for their name and a link back with the job.
            Wrap(
              spacing: context.space(),
              runSpacing: context.space(),
              children: [
                JobOpeningPostedWidget(jobOpening: jobOpening),
                JobOpeningPillWidget(
                  icon: Icons.public_rounded,
                  label: jobOpening.sourceName,
                ),
                JobOpeningPillWidget(
                  icon: Icons.event_rounded,
                  label: jobOpening.formattedPublishedAt(context),
                ),
                for (final jobType in jobOpening.jobTypes)
                  JobOpeningPillWidget(
                    icon: Icons.work_history_outlined,
                    label: jobType.formattedJobType,
                  ),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: context.space()),
              child: Wrap(
                spacing: context.space(factor: 1.5),
                runSpacing: context.space(factor: 1.5),
                children: [
                  DSButtonWidget(
                    label: context.localizations.jobOpeningApply(
                      jobOpening.sourceName,
                    ),
                    icon: Icons.arrow_outward_rounded,
                    iconDirection: DSButtonIconDirection.right,
                    isExpanded: false,
                    onPressed: () => context.bloc.add(const ApplyClickEvent()),
                  ),
                  if (isTailoredCvAvailable)
                    DSButtonWidget(
                      label: context.localizations.jobOpeningTailoredCv,
                      icon: Icons.description_outlined,
                      variant: DSButtonVariant.secondary,
                      isExpanded: false,
                      onPressed: () {
                        context.bloc.add(const TailoredCvClickEvent());
                        CvExportScreen.navigate(
                          context,
                          tailoringTarget: jobOpening.toCvTailoringTarget(),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, curve: Curves.easeOutCubic);
  }
}

class _ScoreBadgeWidget extends StatelessWidget {
  const _ScoreBadgeWidget({required this.score, required this.size});

  final int score;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final tier = JobFitTier.of(score);
    final tierColor = tier.color(context).color;

    return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: context.space(factor: 1.5),
          children: [
            Container(
              padding: EdgeInsets.all(context.space(factor: 1.5)),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.surface.surfaceContainerLow.color.withAlpha(235),
                boxShadow: [
                  BoxShadow(color: tierColor.withAlpha(36), blurRadius: 24),
                ],
              ),
              child: JobFitScoreWidget(score: score, size: size),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: context.space(factor: 1.5),
                vertical: context.space(factor: 0.5),
              ),
              decoration: BoxDecoration(
                color: tierColor.withAlpha(36),
                borderRadius: BorderRadius.circular(100),
              ),
              child: DSTextWidget(
                tier.label(context),
                style: context.typography.emphasizedLabelLarge,
                color: tier.color(context),
              ),
            ),
          ],
        )
        .animate()
        .fadeIn(delay: 150.ms, duration: 500.ms)
        .scale(
          begin: const Offset(0.92, 0.92),
          curve: Curves.easeOutBack,
          duration: 600.ms,
        );
  }
}
