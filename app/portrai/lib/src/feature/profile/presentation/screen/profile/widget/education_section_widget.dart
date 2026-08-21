part of 'content_widget.dart';

class _EducationSectionWidget extends StatelessWidget {
  const _EducationSectionWidget({
    required this.profile,
    required this.isDesktop,
  });

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    if (profile.educations.isEmpty) return const SizedBox.shrink();

    return _SectionWidget(
      label: 'Education',
      isDesktop: isDesktop,
      children: profile.educations.map((education) {
        return DSCardWidget(
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (isDesktop) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: context.space(factor: 2.5),
                  children: [
                    const _EducationIcon(),
                    Expanded(
                      child: _DesktopEducationDetails(education: education),
                    ),
                  ],
                );
              }

              return _MobileEducationDetails(education: education);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _EducationIcon extends StatelessWidget {
  const _EducationIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.space(factor: 1.5)),
      decoration: BoxDecoration(
        color: context.colorPalette.brand.primaryContainer.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
      ),
      child: Icon(
        Icons.school_rounded,
        size: 28,
        color: context.colorPalette.brand.primary.color,
      ),
    );
  }
}

class _DesktopEducationDetails extends StatelessWidget {
  const _DesktopEducationDetails({required this.education});

  final EducationEntity education;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: context.space(factor: 0.75),
      children: [
        DSTextWidget(
          education.degree,
          style: context.typography.emphasizedTitleLarge,
          color: context.colorPalette.neutral.grey9,
        ),
        DSTextWidget(
          education.field,
          style: context.typography.bodyLarge,
          color: context.colorPalette.brand.primary,
        ),
        DSTextWidget(
          education.institution,
          style: context.typography.bodyMedium,
          color: context.colorPalette.neutral.grey8,
        ),
        Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              size: 14,
              color: context.colorPalette.neutral.grey7.color,
            ),
            const DSHorizontalSpacerWidget(0.5),
            Flexible(
              child: DSTextWidget(
                education.location,
                style: context.typography.bodySmall,
                color: context.colorPalette.neutral.grey7,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MobileEducationDetails extends StatelessWidget {
  const _MobileEducationDetails({required this.education});

  final EducationEntity education;

  @override
  Widget build(BuildContext context) {
    return DSCardWidget(
      elevation: context.dimen.elevationLevel1,
      child: Padding(
        padding: EdgeInsets.all(context.space(factor: 2)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: context.space(factor: 0.5),
          children: [
            const _EducationIcon(),
            DSTextWidget(
              education.degree,
              style: context.typography.emphasizedBodyLarge,
              color: context.colorPalette.neutral.grey9,
            ),
            DSTextWidget(
              education.field,
              style: context.typography.bodyMedium,
              color: context.colorPalette.brand.primary,
            ),
            DSTextWidget(
              education.institution,
              style: context.typography.bodyMedium,
              color: context.colorPalette.neutral.grey8,
            ),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: context.getTextHeight(context.typography.bodySmall, 1),
                  color: context.colorPalette.neutral.grey7.color,
                ),
                const DSHorizontalSpacerWidget(0.5),
                DSTextWidget(
                  education.location,
                  style: context.typography.bodySmall,
                  color: context.colorPalette.neutral.grey7,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
