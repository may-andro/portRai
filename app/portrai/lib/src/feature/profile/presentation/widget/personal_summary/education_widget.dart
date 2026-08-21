part of 'personal_summary_widget.dart';

class _EducationWidget extends StatelessWidget {
  const _EducationWidget({required this.education});

  final EducationEntity education;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.school_rounded,
          size: context.educationIconSize,
          color: context.colorPalette.neutral.grey10.color,
        ),
        const DSHorizontalSpacerWidget(2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: context.space(factor: 0.5),
            mainAxisSize: MainAxisSize.min,
            children: [
              DSTextWidget(
                education.degree,
                style: context.typography.emphasizedBodyLarge,
                color: context.colorPalette.neutral.grey10,
              ),
              DSTextWidget(
                '${education.institution} - ${education.endDate.substring(0, 4)}',
                style: context.typography.emphasizedTitleSmall,
                color: context.colorPalette.neutral.grey8,
              ),
              DSTextWidget(
                education.location,
                style: context.typography.emphasizedTitleSmall,
                color: context.colorPalette.neutral.grey8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

extension on BuildContext {
  double get educationIconSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: 5);
      case DSDeviceResolution.tablet:
        return space(factor: 5);
      case DSDeviceResolution.desktop:
        return space(factor: 4);
    }
  }
}
