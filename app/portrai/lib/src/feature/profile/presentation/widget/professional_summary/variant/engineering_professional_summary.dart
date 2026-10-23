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

  /// How much larger the illustration is drawn on mobile. The artwork has an
  /// empty margin around it, so only that margin goes past the area.
  static const _mobileIllustrationScale = 1.25;

  @override
  Widget buildVisual(BuildContext context, ProfessionalSummaryScope scope) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        if (scope.isMobile) {
          final width = shortestSide * _mobileIllustrationScale;
          return OverflowBox(
            maxWidth: width,
            maxHeight: width,
            child: DSLottieIllustrationWidget(
              illustration: DSLottieIllustration.techStack,
              width: width,
            ),
          );
        }
        return Center(
          child: DSLottieIllustrationWidget(
            illustration: DSLottieIllustration.techStack,
            width: min(
              shortestSide,
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
      // Mobile keeps the card short and leaves the stack out.
      stack: scope.isMobile ? const [] : stack,
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
