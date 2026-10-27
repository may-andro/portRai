part of 'professional_summary_widget.dart';

class _SocialLinksWidget extends StatelessWidget {
  const _SocialLinksWidget({
    this.names,
    required this.socialLinkSize,
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final Set<String>? names;
  final bool hasHorizontalPadding;
  final double socialLinkSize;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    bool isShown(String name) =>
        names == null || names!.contains(name.toLowerCase());
    final links = state.appSocialLinks.where((link) => isShown(link.name));
    final buttons = [
      for (final link in links)
        (
          name: link.name,
          brand: _brandOf(link.name),
          image: link.image,
          onTap: () =>
              context.bloc.add(OpenExternalUrlEvent(link.url, link.name)),
        ),
      if (isShown('resume'))
        (
          name: context.localizations.downloadResume,
          brand: DSBrandIcon.resume as DSBrandIcon?,
          image: '',
          onTap: () {
            context.bloc.add(const ResumeClickEvent());
            CvExportScreen.navigate(context);
          },
        ),
    ];
    if (buttons.isEmpty) return const SizedBox.shrink();

    // A tint of the hire button's primary, so the icons sit behind it.
    final brandColors = context.colorPalette.brand;

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child: Wrap(
        spacing: context.space(factor: 2),
        children: buttons.mapIndexed((index, button) {
          final delay = (100 + index * 300).ms;
          final begin = 1 + (index * 0.2);
          final brand = button.brand;
          if (brand != null) {
            return _HoverScaleWidget(
              child: DSBrandIconButtonWidget(
                brand: brand,
                color: brandColors.primaryContainer,
                onColor: brandColors.onPrimaryContainer,
                diameter: context.socialHandleIconSize,
                tooltip: button.name,
                onTap: button.onTap,
              ),
            )._slideIn(isVisible: isVisible, delay: delay, begin: begin);
          }

          return InkWell(
            onTap: button.onTap,
            customBorder: const CircleBorder(),
            splashColor: context.colorPalette.brand.secondary.color.withAlpha(
              30,
            ),
            child: _CardWidget(
              animationDelay: delay,
              animationBegin: begin,
              isVisible: isVisible,
              child: DSNetworkImageWidget(
                url: button.image,
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

  static DSBrandIcon? _brandOf(String name) {
    if (name.trim().toLowerCase() == 'portfolio') return DSBrandIcon.website;
    return DSBrandIcon.fromName(name);
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
                        context.colorPalette.brand.secondary.color.withAlpha(
                          20,
                        ),
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
                    color: context.colorPalette.utility.shadow.color.withAlpha(
                      isHovering ? 30 : 12,
                    ),
                    blurRadius:
                        context.dimen.radiusLevel1.value * (isHovering ? 2 : 1),
                    offset: Offset(0, isHovering ? 8 : 4),
                  ),
                ],
              ),
              child: child,
            ),
          ),
        );
      },
    )._slideIn(
      isVisible: isVisible,
      delay: animationDelay,
      begin: animationBegin,
    );
  }
}

extension on Widget {
  Widget _slideIn({
    required bool isVisible,
    required Duration delay,
    required double begin,
  }) {
    return animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: begin,
          duration: 300.ms,
          delay: delay,
          curve: Curves.easeOut,
        )
        .fadeIn(delay: delay, duration: 300.ms);
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
