part of 'content_widget.dart';

class _JobOpeningCardWidget extends StatelessWidget {
  const _JobOpeningCardWidget({required this.jobOpening});

  static const _maxSkillTags = 5;

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');
    return DSCardWidget(
      backgroundColor: palette.inverseSurface,
      radius: context.dimen.radiusLevel2,
      elevation: context.dimen.elevationLevel1,
      child: InkWell(
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
        onTap: () {
          context.bloc.add(const JobOpeningClickEvent());
          context.pushScreen(
            JobOpeningModuleRoute.jobOpening,
            pathParameters: {
              JobOpeningScreen.routePathParameter: jobOpening.id,
            },
          );
        },
        child: Padding(
          padding: EdgeInsets.all(context.space(factor: 2)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: DSTextWidget(
                      jobOpening.title,
                      color: palette.neutral.grey1,
                      style: context.typography.titleMedium,
                    ),
                  ),
                  const DSHorizontalSpacerWidget(1),
                  DSTextWidget(
                    localizations.jobOpeningScore(jobOpening.score),
                    color: palette.brand.primary,
                    style: context.typography.emphasizedLabelLarge,
                  ),
                ],
              ),
              DSTextWidget(
                companyAndLocation,
                color: palette.neutral.grey3,
                style: context.typography.bodyMedium,
              ),
              if (jobOpening.matchedSkills.isNotEmpty)
                Wrap(
                  spacing: context.space(),
                  runSpacing: context.space(),
                  children: [
                    for (final skill in jobOpening.matchedSkills.take(
                      _maxSkillTags,
                    ))
                      DSTagWidget(label: skill),
                  ],
                ),
              DSTextWidget(
                localizations.jobOpeningSourceAndDate(
                  jobOpening.sourceName,
                  jobOpening.formattedPublishedAt(context),
                ),
                color: palette.neutral.grey3,
                style: context.typography.labelMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
