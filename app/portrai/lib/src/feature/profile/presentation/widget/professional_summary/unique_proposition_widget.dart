part of 'professional_summary_widget.dart';

class _UniquePropositionWidget extends StatelessWidget {
  const _UniquePropositionWidget({
    required this.label,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final String label;
  final bool hasHorizontalPadding;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          DSTextWidget(
                label,
                style: context.labelTextStyle,
                color: context.colorPalette.surface.onSurface,
              )
              .animate(target: isVisible ? 1 : 0)
              .slideY(
                begin: -0.5,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 100.ms),
    );
  }
}

extension on BuildContext {
  DSTextStyle get labelTextStyle {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return typography.emphasizedHeadlineSmall;
      case DSDeviceResolution.tablet:
        return typography.displaySmall;
      case DSDeviceResolution.desktop:
        return typography.displaySmall;
    }
  }
}
