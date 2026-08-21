part of 'content_widget.dart';

class _AboutMeSectionWidget extends StatelessWidget {
  const _AboutMeSectionWidget({required this.profile, required this.isDesktop});

  final ProfileEntity profile;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    return _SectionWidget(
      label: 'About Me',
      isDesktop: isDesktop,
      children: [
        _ElevatorPitchWidget(
          elevatorPitch: profile.elevatorPitch,
          isDesktop: isDesktop,
        ),
        DSButtonWidget(
          label: 'Get in Touch',
          icon: Icons.download_rounded,
          iconDirection: DSButtonIconDirection.right,
          border: DSButtonBorder.rounded,
          onPressed: () {},
        ),
      ],
    );
  }
}

class _ElevatorPitchWidget extends StatelessWidget {
  const _ElevatorPitchWidget({
    required this.elevatorPitch,
    required this.isDesktop,
  });

  final String elevatorPitch;
  final bool isDesktop;

  @override
  Widget build(BuildContext context) {
    final textStyle = isDesktop
        ? context.typography.bodyLarge
        : context.typography.bodyMedium;
    return Container(
      padding: EdgeInsets.all(context.space(factor: 2)),
      decoration: BoxDecoration(
        color: context.colorPalette.brand.primaryContainer.color,
        borderRadius: BorderRadius.circular(context.dimen.radiusLevel2.value),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.rocket_launch_rounded,
            color: context.colorPalette.brand.primary.color,
            size: context.getTextHeight(textStyle, 1),
          ),
          const DSHorizontalSpacerWidget(1.5),
          Expanded(
            child: DSTextWidget(
              elevatorPitch,
              style: textStyle,
              color: context.colorPalette.neutral.grey9,
            ),
          ),
        ],
      ),
    );
  }
}
