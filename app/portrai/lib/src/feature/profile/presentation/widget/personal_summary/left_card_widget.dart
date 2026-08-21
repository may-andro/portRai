part of 'personal_summary_widget.dart';

class _LeftCardWidget extends StatelessWidget {
  const _LeftCardWidget({
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
          padding: context.leftCardPadding,
          decoration: BoxDecoration(
            color: cardColor.color,
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(context.dimen.radiusLevel2.value),
              bottomRight: Radius.circular(context.dimen.radiusLevel2.value),
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
          begin: -0.3,
          duration: 300.ms,
          delay: animationDelay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: 300.ms, duration: 300.ms);
  }
}

extension on BuildContext {
  EdgeInsets get leftCardPadding {
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
          left: space(factor: 5),
          right: space(factor: 2),
          top: space(factor: 2),
          bottom: space(factor: 2),
        );
      case DSDeviceResolution.desktop:
        return EdgeInsets.only(
          right: space(factor: 2),
          left: width * 0.15,
          top: space(factor: 2),
          bottom: space(factor: 2),
        );
    }
  }
}
