part of 'professional_summary_widget.dart';

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget({required this.profile, required this.isVisible});

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSVerticalSpacerWidget(5),
        _UniquePropositionWidget(
          label: profile.uniqueValueProposition,
          isVisible: isVisible,
          hasHorizontalPadding: true,
        ),
        const DSVerticalSpacerWidget(3),
        _ElevatorPitchWidget(
          label: profile.elevatorPitch,
          isVisible: isVisible,
          hasHorizontalPadding: true,
        ),
        const DSVerticalSpacerWidget(3),
        SizedBox(
          height: context.space(factor: 30),
          child: Stack(
            children: [
              Positioned(
                left: context.space(factor: 5),
                top: 0,
                bottom: 0,
                width: context.width * 0.5,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _HireButtonWidget(
                      isVisible: isVisible,
                      hasHorizontalPadding: false,
                    ),
                    const DSVerticalSpacerWidget(2),
                    _SocialLinksWidget(
                      socialLinkSize: context.space(factor: 5),
                      isVisible: isVisible,
                      hasHorizontalPadding: false,
                    ),
                    const DSVerticalSpacerWidget(2),
                    _ProjectYearsWidget(
                      isVisible: isVisible,
                      animationDelay: 900.ms,
                    ),
                  ],
                ),
              ),
              Positioned(
                right: context.space(factor: 2),
                top: 0,
                bottom: 0,
                width: context.width * 0.5,
                child: _ProfileImageWidget(isVisible: isVisible),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
