part of 'professional_summary_widget.dart';

class _SocialLinksWidget extends StatelessWidget {
  const _SocialLinksWidget({
    required this.socialLinkSize,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final bool hasHorizontalPadding;
  final double socialLinkSize;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child: Wrap(
        spacing: context.space(factor: 2),
        children: state.appSocialLinks.mapIndexed((index, socialHandle) {
          return InkWell(
            onTap: () {
              context.bloc.add(
                OpenExternalUrlEvent(socialHandle.url, socialHandle.name),
              );
            },
            customBorder: const CircleBorder(),
            splashColor: Colors.blue,
            child: _CardWidget(
              animationDelay: (100 + index * 300).ms,
              animationBegin: 1 + (index * 0.2),
              isVisible: isVisible,
              child: DSNetworkImageWidget(
                url: socialHandle.image,
                color: context.colorPalette.brand.secondary,
                width: context.socialHandleIconSize,
                height: context.socialHandleIconSize,
                fit: BoxFit.cover,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  const _CardWidget({
    required this.child,
    required this.animationBegin,
    required this.isVisible,
    this.animationDelay = Duration.zero,
  });

  final Widget child;
  final Duration animationDelay;
  final double animationBegin;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final cardColor = context.colorPalette.surface.inverseOnSurface;
    final borderColor = context.colorPalette.brand.secondary;
    return Container(
          height: context.socialHandleIconSize,
          width: context.socialHandleIconSize,
          padding: EdgeInsets.all(context.space()),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: cardColor.color,
            border: Border.all(color: borderColor.color, width: 2),
            boxShadow: [
              BoxShadow(
                color: borderColor.color.withAlpha(70),
                blurRadius: context.dimen.radiusLevel1.value,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: animationBegin,
          duration: 300.ms,
          delay: animationDelay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: animationDelay, duration: 300.ms);
  }
}

extension on BuildContext {
  double get socialHandleIconSize {
    switch (deviceResolution) {
      case DSDeviceResolution.mobile:
        return space(factor: DSIconButtonSize.large.heightFactor);
      case DSDeviceResolution.tablet:
        return space(factor: DSIconButtonSize.medium.heightFactor);
      case DSDeviceResolution.desktop:
        return space(factor: DSIconButtonSize.small.heightFactor);
    }
  }
}
