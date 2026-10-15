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
            splashColor: context.colorPalette.brand.secondary.color.withAlpha(
              30,
            ),
            child: _CardWidget(
              animationDelay: (100 + index * 300).ms,
              animationBegin: 1 + (index * 0.2),
              isVisible: isVisible,
              child: DSNetworkImageWidget(
                url: socialHandle.image,
                color: context.colorPalette.brand.onSecondaryContainer,
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
    final cardColor = context.colorPalette.brand.secondaryContainer;
    final borderColor = context.colorPalette.outline.outlineVariant;
    return DSHoverableContainerWidget(
          builder: (context, isHovering) {
            return AnimatedSlide(
              duration: 200.ms,
              curve: Curves.easeOutBack,
              offset: Offset(0, isHovering ? -0.12 : 0),
              child: AnimatedScale(
                duration: 200.ms,
                curve: Curves.easeOutBack,
                scale: isHovering ? 1.15 : 1,
                child: AnimatedContainer(
                  duration: 200.ms,
                  height: context.socialHandleIconSize,
                  width: context.socialHandleIconSize,
                  padding: EdgeInsets.all(context.space()),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isHovering
                        ? Color.alphaBlend(
                            context.colorPalette.brand.secondary.color
                                .withAlpha(20),
                            cardColor.color,
                          )
                        : cardColor.color,
                    border: Border.all(
                      color: isHovering
                          ? context.colorPalette.brand.secondary.color
                          : borderColor.color,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: context.colorPalette.utility.shadow.color
                            .withAlpha(isHovering ? 30 : 12),
                        blurRadius:
                            context.dimen.radiusLevel1.value *
                            (isHovering ? 2 : 1),
                        offset: Offset(0, isHovering ? 8 : 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
              ),
            );
          },
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
