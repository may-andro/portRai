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
                child: DSButtonWidget(
                  label: context.localizations.hireMe,
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () {
                    context.bloc.add(OpenEmailClientEvent(state.profile.email));
                  },
                  iconDirection: DSButtonIconDirection.right,
                  border: DSButtonBorder.rounded,
                  size: DSButtonSize.small,
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
