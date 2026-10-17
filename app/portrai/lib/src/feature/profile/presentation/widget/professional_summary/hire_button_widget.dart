part of 'professional_summary_widget.dart';

class _HireButtonWidget extends StatelessWidget {
  const _HireButtonWidget({
    required this.hasHorizontalPadding,
    required this.isVisible,
    this.showResume = true,
    this.resumeFirst = false,
  });

  final bool hasHorizontalPadding;
  final bool isVisible;
  final bool showResume;
  final bool resumeFirst;

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    final hasResume = showResume && state.profile.resume.url.isNotEmpty;
    final hireMe = _HoverScaleWidget(
      child: DSButtonWidget(
        label: context.localizations.hireMe,
        icon: Icons.arrow_forward_rounded,
        onPressed: () {
          context.bloc.add(OpenEmailClientEvent(state.profile.email));
        },
        iconDirection: DSButtonIconDirection.right,
        variant: hasResume && resumeFirst
            ? DSButtonVariant.secondary
            : DSButtonVariant.primary,
        border: DSButtonBorder.rounded,
        size: DSButtonSize.small,
      ),
    );
    final resume = hasResume
        ? _HoverScaleWidget(
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
              variant: resumeFirst
                  ? DSButtonVariant.primary
                  : DSButtonVariant.secondary,
              border: DSButtonBorder.rounded,
              size: DSButtonSize.small,
            ),
          )
        : null;

    return Padding(
      padding: hasHorizontalPadding
          ? context.horizontalScreenPadding
          : EdgeInsets.zero,
      child:
          FittedBox(
                child: Row(
                  spacing: context.space(factor: 1.5),
                  children: resumeFirst ? [?resume, hireMe] : [hireMe, ?resume],
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
