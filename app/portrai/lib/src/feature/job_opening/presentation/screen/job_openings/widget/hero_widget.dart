part of 'content_widget.dart';

/// The page title and summary, with a person looking out through
/// binoculars beside it on wide screens and above it on phones.
class _HeroWidget extends StatelessWidget {
  const _HeroWidget({required this.state});

  final JobOpeningsState state;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final isWide = !context.isMobile;
    final illustration = RepaintBoundary(
      child: DSLottieIllustrationWidget(
        illustration: DSLottieIllustration.binoculars,
        width: context.space(factor: isWide ? 26 : 24),
      ),
    );
    final copy = _HeroCopyWidget(state: state);

    return ColoredBox(
      color: palette.background.color,
      child: PageChromeWidget(
        closeColor: palette.neutral.grey10.color,
        actions: const [_SignOutButtonWidget()],
        child: JobOpeningPageColumnWidget(
          verticalPadding: context.space(factor: isWide ? 5 : 3),
          child: isWide
              ? Row(
                  spacing: context.space(factor: 4),
                  children: [
                    Expanded(child: copy),
                    illustration,
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: context.space(factor: 2),
                  children: [
                    Center(child: illustration),
                    copy,
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
