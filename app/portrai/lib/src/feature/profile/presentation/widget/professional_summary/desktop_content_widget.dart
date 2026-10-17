part of 'professional_summary_widget.dart';

class _DesktopContentWidget extends StatelessWidget {
  const _DesktopContentWidget({
    required this.profile,
    required this.variant,
    required this.isVisible,
  });

  final ProfileEntity profile;
  final ProfessionalSummaryVariant variant;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final scope = ProfessionalSummaryScope(
      profile: profile,
      isVisible: isVisible,
      resolution: DSDeviceResolution.desktop,
    );

    return Padding(
      padding: EdgeInsets.only(left: context.width * 0.15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: context.space(factor: 3)),
              child: _ProfessionalSummaryWidget(profile, variant, isVisible),
            ),
          ),
          Expanded(
            child: Container(
              height: _ProfessionalSummaryWidget.height(context),
              alignment: Alignment.bottomCenter,
              margin: EdgeInsets.only(
                left: context.space(factor: 4),
                right: context.space(factor: 3),
              ),
              child: variant.buildVisual(context, scope),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfessionalSummaryWidget extends StatelessWidget {
  const _ProfessionalSummaryWidget(this.profile, this.variant, this.isVisible);

  final ProfessionalSummaryVariant variant;

  final ProfileEntity profile;
  final bool isVisible;

  static double height(BuildContext context) {
    return context.getTextHeight(context.typography.displaySmall, 3) +
        context.space(factor: 3) +
        context.getTextHeight(context.typography.titleSmall, 3) +
        context.space(factor: 12) +
        context.space(factor: 3) +
        DSButtonSize.small.height +
        context.space(factor: 2) +
        context.space(factor: 3);
  }

  @override
  Widget build(BuildContext context) {
    final scope = ProfessionalSummaryScope(
      profile: profile,
      isVisible: isVisible,
      resolution: DSDeviceResolution.desktop,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        variant.buildHeader(context, scope),
        const DSVerticalSpacerWidget(2),
        variant.buildBody(context, scope),
      ],
    );
  }
}
