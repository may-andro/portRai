part of 'personal_summary_widget.dart';

class _RightCardWidget extends StatelessWidget {
  const _RightCardWidget({
    required this.child,
    required this.isVisible,
    this.animationDelay = Duration.zero,
    this.margin = EdgeInsets.zero,
  });

  final Widget child;
  final EdgeInsets margin;
  final bool isVisible;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.colorPalette.brand.secondaryContainer;

    return Container(
          width: double.maxFinite,
          alignment: Alignment.centerLeft,
          margin: margin,
          padding: context.rightCardPadding,
          decoration: BoxDecoration(
            color: cardColor.color,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(context.dimen.radiusLevel2.value),
              bottomLeft: Radius.circular(context.dimen.radiusLevel2.value),
            ),
            boxShadow: [
              BoxShadow(
                color: cardColor.color.withAlpha(70),
                blurRadius: context.dimen.radiusLevel1.value,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
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
  EdgeInsets get rightCardPadding {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return EdgeInsets.only(
          left: space(factor: 3),
          right: space(factor: 3),
          top: space(factor: 2),
          bottom: space(factor: 2),
        );
      case DSDeviceResolution.tablet:
        return EdgeInsets.only(
          left: space(factor: 2),
          right: space(factor: 5),
          top: space(factor: 2),
          bottom: space(factor: 2),
        );
      case DSDeviceResolution.desktop:
        return EdgeInsets.only(
          left: space(factor: 2),
          right: width * 0.15,
          top: space(factor: 2),
          bottom: space(factor: 2),
        );
    }
  }
}
