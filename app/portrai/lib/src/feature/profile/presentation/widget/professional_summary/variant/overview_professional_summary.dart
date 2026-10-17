part of '../professional_summary_widget.dart';

/// Broad introduction for visitors without a specific goal.
class OverviewProfessionalSummary extends ProfessionalSummaryVariant {
  const OverviewProfessionalSummary();

  @override
  String headline(ProfileEntity profile) => profile.uniqueValueProposition;

  @override
  String pitch(ProfileEntity profile) => profile.elevatorPitch;

  @override
  Widget buildBody(BuildContext context, ProfessionalSummaryScope scope) {
    final padding = scope.bodyHasHorizontalPadding;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _FactsWidget(
          facts: [
            _Fact(
              icon: Icons.work_outline_rounded,
              label:
                  '${scope.profile.currentRole}  ·  '
                  '${scope.profile.currentCompany}',
            ),
          ],
          isVisible: scope.isVisible,
          hasHorizontalPadding: padding,
        ),
        const DSVerticalSpacerWidget(2),
        if (scope.isMobile) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.space(factor: 3)),
            child: _ProjectYearsWidget(
              isVisible: scope.isVisible,
              animationDelay: 100.ms,
            ),
          ),
          const DSVerticalSpacerWidget(2),
        ],
        _HireButtonWidget(
          isVisible: scope.isVisible,
          hasHorizontalPadding: padding,
        ),
        const DSVerticalSpacerWidget(2),
        _SocialLinksWidget(
          socialLinkSize: context.space(
            factor: scope.isMobile
                ? 6
                : scope.isTablet
                ? 5
                : 4,
          ),
          isVisible: scope.isVisible,
          hasHorizontalPadding: padding,
        ),
        if (scope.isTablet) ...[
          const DSVerticalSpacerWidget(2),
          _ProjectYearsWidget(
            isVisible: scope.isVisible,
            animationDelay: 900.ms,
          ),
        ],
      ],
    );
  }
}
