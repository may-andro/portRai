part of 'professional_summary_widget.dart';

class _HireButtonWidget extends StatelessWidget {
  const _HireButtonWidget({
    required this.hasHorizontalPadding,
    required this.isVisible,
  });

  final bool hasHorizontalPadding;
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
      child:
          FittedBox(
                child: Row(
                  spacing: context.space(factor: 1.5),
                  children: [
                    _HoverScaleWidget(
                      child: DSButtonWidget(
                        label: context.localizations.hireMe,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          context.bloc.add(
                            OpenEmailClientEvent(state.profile.email),
                          );
                        },
                        iconDirection: DSButtonIconDirection.right,
                        border: DSButtonBorder.rounded,
                        size: DSButtonSize.small,
                      ),
                    ),
                    if (state.profile.resume.url.isNotEmpty)
                      _HoverScaleWidget(
                        child: DSButtonWidget(
                          label: context.localizations.downloadResume,
                          icon: Icons.download_rounded,
                          onPressed: () {
                            context.bloc.add(
                              OpenExternalUrlEvent(
                                state.profile.resume.url,
                                context.localizations.downloadResume,
                              ),
                            );
                          },
                          variant: DSButtonVariant.secondary,
                          border: DSButtonBorder.rounded,
                          size: DSButtonSize.small,
                        ),
                      ),
                  ],
                ),
              )
              .animate(target: isVisible ? 1 : 0)
              .slideX(
                begin: -0.5,
                end: 0,
                duration: 300.ms,
                delay: 100.ms,
                curve: Curves.easeOut,
              )
              .fadeIn(duration: 300.ms, delay: 100.ms),
    );
  }
}

class _HoverScaleWidget extends StatelessWidget {
  const _HoverScaleWidget({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedScale(
          duration: 180.ms,
          curve: Curves.easeOutBack,
          scale: isHovering ? 1.07 : 1,
          child: child,
        );
      },
    );
  }
}
