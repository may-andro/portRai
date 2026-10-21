part of 'content_widget.dart';

class _HeroWidget extends StatelessWidget {
  const _HeroWidget({required this.state});

  final JobOpeningsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isWide = !context.isMobile;

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
                          Expanded(child: _HeroCopyWidget(state: state)),
                          SizedBox(
                            width: 400,
                            child: _ControlCardWidget(state: state),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        spacing: context.space(factor: 3),
                        children: [
                          _HeroCopyWidget(state: state),
                          _ControlCardWidget(state: state),
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
  const _HeroCopyWidget({required this.state});

  final JobOpeningsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final jobOpenings = state.jobOpenings;
    final bestScore = jobOpenings.isEmpty
        ? null
        : jobOpenings.map((jobOpening) => jobOpening.score).reduce(max);
    final lastFetchedAt = jobOpenings.isEmpty
        ? null
        : jobOpenings
              .map((jobOpening) => jobOpening.fetchedAt)
              .reduce(
                (first, second) => first.isAfter(second) ? first : second,
              );

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
              localizations.jobOpeningsTitle,
              style: context.isMobile
                  ? context.typography.emphasizedHeadlineLarge
                  : context.typography.emphasizedDisplayMedium,
              color: palette.neutral.grey10,
            ),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: context.space(factor: 75)),
              child: DSTextWidget(
                localizations.jobOpeningsDescription,
                style: context.typography.bodyLarge,
                color: palette.neutral.grey8,
              ),
            ),
            if (state.status == JobOpeningsStatus.loaded &&
                jobOpenings.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(top: context.space()),
                child: Wrap(
                  spacing: context.space(),
                  runSpacing: context.space(),
                  children: [
                    JobOpeningPillWidget(
                      icon: Icons.work_outline_rounded,
                      label: localizations.jobOpeningsMatchCount(
                        jobOpenings.length,
                      ),
                    ),
                    if (bestScore != null)
                      JobOpeningPillWidget(
                        icon: Icons.auto_awesome_rounded,
                        label: localizations.jobOpeningsBestFit(bestScore),
                      ),
                    if (lastFetchedAt != null)
                      JobOpeningPillWidget(
                        icon: Icons.update_rounded,
                        label: localizations.jobOpeningsUpdatedOn(
                          DateFormat.yMMMd(
                            Localizations.localeOf(context).toString(),
                          ).format(lastFetchedAt),
                        ),
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
