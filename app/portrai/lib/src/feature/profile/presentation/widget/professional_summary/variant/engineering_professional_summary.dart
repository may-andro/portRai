part of '../professional_summary_widget.dart';

/// For developers: the stack and the numbers presented like code, a tech
/// stack illustration instead of the portrait, and a blueprint grid
/// background.
class EngineeringProfessionalSummary extends ProfessionalSummaryVariant {
  const EngineeringProfessionalSummary({this.stack = const []});

  final List<String> stack;

  @override
  String headline(ProfileEntity profile) => profile.uniqueValueProposition;

  @override
  String pitch(ProfileEntity profile) => profile.summary;

  @override
  bool get hasFlexibleTabletHeight => true;

  @override
  Widget buildVisual(BuildContext context, ProfessionalSummaryScope scope) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.techStack,
            width: min(
              constraints.biggest.shortestSide,
              scope.resolution == DSDeviceResolution.tablet ? 240 : 480,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget buildBackdrop(
    BuildContext context, {
    required bool isVisible,
    required List<String> projectImages,
  }) {
    return _BlueprintGridWidget(isVisible: isVisible);
  }

  @override
  Widget buildBody(BuildContext context, ProfessionalSummaryScope scope) {
    final padding = scope.bodyHasHorizontalPadding;
    final card = _CodeCardWidget(
      profile: scope.profile,
      stack: stack,
      isVisible: scope.isVisible,
      hasHorizontalPadding: padding,
    );
    if (scope.resolution == DSDeviceResolution.tablet) return card;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        card,
        const DSVerticalSpacerWidget(1),
        _actions(context, scope),
      ],
    );
  }

  @override
  Widget buildTabletActions(
    BuildContext context,
    ProfessionalSummaryScope scope,
  ) => _actions(context, scope);

  Widget _actions(BuildContext context, ProfessionalSummaryScope scope) {
    return Padding(
      padding: scope.bodyHasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child: Wrap(
        spacing: context.space(factor: 2),
        runSpacing: context.space(factor: 1.5),
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          _HireButtonWidget(
            isVisible: scope.isVisible,
            hasHorizontalPadding: false,
            showResume: false,
          ),
          _SocialLinksWidget(
            socialLinkSize: context.space(factor: scope.isMobile ? 6 : 4),
            isVisible: scope.isVisible,
            hasHorizontalPadding: false,
          ),
        ],
      ),
    );
  }
}
