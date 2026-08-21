part of 'personal_summary_widget.dart';

class _DetailButtonWidget extends StatelessWidget {
  const _DetailButtonWidget({
    required this.isVisible,
    required this.animationDelay,
    this.margin = EdgeInsets.zero,
  });

  final bool isVisible;
  final Duration animationDelay;
  final EdgeInsets margin;

  @override
  Widget build(BuildContext context) {
    return Container(
          alignment: Alignment.bottomRight,
          margin: margin,
          child: DSIconButtonWidget(
            Icons.arrow_circle_right_rounded,
            iconColor: context.colorPalette.brand.onSecondaryContainer,
            buttonColor: context.colorPalette.brand.secondaryContainer,
            size: context.buttonSize,
            elevation: context.dimen.elevationLevel2,
            onPressed: () => ProfileScreen.navigate(context),
          ),
        )
        .animate(target: isVisible ? 1 : 0)
        .slideX(
          begin: 0.3,
          duration: 300.ms,
          delay: animationDelay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: 300.ms, duration: 300.ms);
  }
}

extension on BuildContext {
  DSIconButtonSize get buttonSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return DSIconButtonSize.large;
      case DSDeviceResolution.tablet:
        return DSIconButtonSize.medium;
      case DSDeviceResolution.desktop:
        return DSIconButtonSize.small;
    }
  }
}
