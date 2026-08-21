part of 'professional_summary_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({required this.profile, required this.isVisible});

  final ProfileEntity profile;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: context.width * 0.15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.space(factor: 3)),
              child: _ProfessionalSummaryWidget(profile, isVisible),
            ),
          ),
          Expanded(
            child: Container(
              height: _ProfessionalSummaryWidget.height(context),
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(right: context.space(factor: 3)),
              child: _ProfileImageWidget(isVisible: isVisible),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalSummaryWidget extends StatelessWidget {
  const _ProfessionalSummaryWidget(this.profile, this.isVisible);

  final ProfileEntity profile;
  final bool isVisible;

  static double height(BuildContext context) {
    return context.getTextHeight(context.typography.displaySmall, 3) +
        context.space(factor: 3) +
        context.getTextHeight(context.typography.titleSmall, 3) +
        context.space(factor: 3) +
        DSButtonSize.small.height +
        context.space(factor: 2) +
        context.space(factor: 3);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _UniquePropositionWidget(
          label: profile.uniqueValueProposition,
          isVisible: isVisible,
          hasHorizontalPadding: false,
        ),
        const DSVerticalSpacerWidget(3),
        _ElevatorPitchWidget(
          label: profile.elevatorPitch,
          isVisible: isVisible,
          hasHorizontalPadding: false,
        ),
        const DSVerticalSpacerWidget(3),
        _HireButtonWidget(isVisible: isVisible, hasHorizontalPadding: false),
        const DSVerticalSpacerWidget(2),
        _SocialLinksWidget(
          socialLinkSize: context.space(factor: 4),
          isVisible: isVisible,
          hasHorizontalPadding: false,
        ),
      ],
    );
  }
}
