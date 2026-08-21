part of 'professional_summary_widget.dart';

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({
    required this.profile,
    required this.isVisible,
    required this.height,
  });

  final ProfileEntity profile;
  final bool isVisible;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSVerticalSpacerWidget(2),
          _UniquePropositionWidget(
            label: profile.uniqueValueProposition,
            isVisible: isVisible,
            hasHorizontalPadding: true,
          ),
          const DSVerticalSpacerWidget(3),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.space(factor: 3)),
            child: _ProjectYearsWidget(
              isVisible: isVisible,
              animationDelay: 100.ms,
            ),
          ),
          const DSVerticalSpacerWidget(2),
          _HireButtonWidget(isVisible: isVisible, hasHorizontalPadding: true),
          const DSVerticalSpacerWidget(2),
          _SocialLinksWidget(
            socialLinkSize: context.space(factor: 6),
            isVisible: isVisible,
            hasHorizontalPadding: true,
          ),
          const DSVerticalSpacerWidget(3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.space()),
              child: _ProfileImageWidget(isVisible: isVisible),
            ),
          ),
        ],
      ),
    );
  }
}
