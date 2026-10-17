part of 'professional_summary_widget.dart';

class _TabletContentWidget extends StatelessWidget {
  const _TabletContentWidget({
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
      resolution: DSDeviceResolution.tablet,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const DSVerticalSpacerWidget(5),
        variant.buildHeader(context, scope),
        const DSVerticalSpacerWidget(3),
        if (variant.hasFlexibleTabletHeight)
          Padding(
            padding: EdgeInsets.only(
              left: context.space(factor: 5),
              right: context.space(factor: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: context.space(factor: 2),
                  children: [
                    Expanded(child: variant.buildBody(context, scope)),
                    Expanded(child: variant.buildVisual(context, scope)),
                  ],
                ),
                const DSVerticalSpacerWidget(2),
                variant.buildTabletActions(context, scope),
                const DSVerticalSpacerWidget(2),
              ],
            ),
          )
        else
          ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: double.infinity,
              minHeight: context.space(factor: 30),
            ),
            child: Stack(
              children: [
                // The body sets the height so it can never overflow; the
                // visual fills whatever height results beside it.
                Padding(
                  padding: EdgeInsets.only(left: context.space(factor: 5)),
                  child: SizedBox(
                    width: context.width * 0.5 - context.space(factor: 7),
                    child: variant.buildBody(context, scope),
                  ),
                ),
                Positioned(
                  right: context.space(factor: 2),
                  top: 0,
                  bottom: 0,
                  width: context.width * 0.5,
                  child: variant.buildVisual(context, scope),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
