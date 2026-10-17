part of 'professional_summary_widget.dart';

class _MobileContentWidget extends StatelessWidget {
  const _MobileContentWidget({
    required this.profile,
    required this.variant,
    required this.isVisible,
    required this.height,
  });

  final ProfileEntity profile;
  final ProfessionalSummaryVariant variant;
  final bool isVisible;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scope = ProfessionalSummaryScope(
      profile: profile,
      isVisible: isVisible,
      resolution: DSDeviceResolution.mobile,
    );

    return SizedBox(
      height: height,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DSVerticalSpacerWidget(2),
          variant.buildHeader(context, scope),
          const DSVerticalSpacerWidget(2),
          variant.buildBody(context, scope),
          const DSVerticalSpacerWidget(3),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.space()),
              child: variant.buildVisual(context, scope),
            ),
          ),
        ],
      ),
    );
  }
}
