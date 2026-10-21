part of 'content_widget.dart';

class _DetailsWidget extends StatelessWidget {
  const _DetailsWidget({required this.jobOpening});

  final JobOpeningEntity jobOpening;

  @override
  Widget build(BuildContext context) {
    final palette = context.colorPalette;
    final localizations = context.localizations;
    final companyAndLocation = [
      jobOpening.company,
      ?jobOpening.location,
    ].join(' · ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: context.space(factor: 2),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(),
          children: [
            DSTextWidget(
              jobOpening.title,
              color: palette.neutral.grey9,
              style: context.typography.emphasizedHeadlineSmall,
            ),
            DSTextWidget(
              companyAndLocation,
              color: palette.neutral.grey7,
              style: context.typography.bodyLarge,
            ),
            DSTextWidget(
              localizations.jobOpeningScore(jobOpening.score),
              color: palette.brand.primary,
              style: context.typography.emphasizedTitleMedium,
            ),
            // The job boards ask for their name and a link back with the job.
            DSTextWidget(
              localizations.jobOpeningSourceAndDate(
                jobOpening.sourceName,
                jobOpening.formattedPublishedAt(context),
              ),
              color: palette.neutral.grey7,
              style: context.typography.labelMedium,
            ),
          ],
        ),
        DSButtonWidget(
          label: localizations.jobOpeningApply(jobOpening.sourceName),
          onPressed: () => context.bloc.add(const ApplyClickEvent()),
        ),
        if (jobOpening.reasons.isNotEmpty)
          DSDetailSectionWidget(
            title: localizations.jobOpeningReasonsTitle,
            child: DSBulletPointListWidget(bulletPoints: jobOpening.reasons),
          ),
        if (jobOpening.matchedSkills.isNotEmpty)
          DSDetailSectionWidget(
            title: localizations.jobOpeningMatchedSkillsTitle,
            child: _SkillTagsWidget(skills: jobOpening.matchedSkills),
          ),
        if (jobOpening.missingSkills.isNotEmpty)
          DSDetailSectionWidget(
            title: localizations.jobOpeningMissingSkillsTitle,
            child: _SkillTagsWidget(skills: jobOpening.missingSkills),
          ),
        DSDetailSectionWidget(
          title: localizations.jobOpeningDescriptionTitle,
          child: DSTextWidget(
            jobOpening.description,
            color: palette.neutral.grey9,
            style: context.typography.bodyMedium,
          ),
        ),
      ],
    );
  }
}

class _SkillTagsWidget extends StatelessWidget {
  const _SkillTagsWidget({required this.skills});

  final List<String> skills;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(),
      runSpacing: context.space(),
      children: [for (final skill in skills) DSTagWidget(label: skill)],
    );
  }
}
