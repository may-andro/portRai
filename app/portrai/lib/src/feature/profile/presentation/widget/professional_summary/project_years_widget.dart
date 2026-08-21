part of 'professional_summary_widget.dart';

class _ProjectYearsWidget extends StatelessWidget {
  const _ProjectYearsWidget({
    required this.isVisible,
    required this.animationDelay,
  });

  final bool isVisible;
  final Duration animationDelay;

  @override
  Widget build(BuildContext context) {
    final state = context.state;

    if (state is! LoadedState) {
      return const SizedBox.shrink();
    }

    return Row(
          spacing: context.space(factor: 2),
          children: [
            _StatItemWidget(
              label: context.localizations.totalExperienceInYears,
              value: state.profile.yearsOfExperience,
              isVisible: isVisible,
              animationDelay: animationDelay,
            ),
            _StatItemWidget(
              label: context.localizations.totalProjectsDelivered,
              value: state.profile.projectsDelivered,
              isVisible: isVisible,
              animationDelay: animationDelay,
            ),
          ],
        )
        .animate(target: isVisible ? 1 : 0)
        .slideY(
          begin: 0.3,
          duration: 300.ms,
          delay: animationDelay,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(delay: animationDelay + 100.ms, duration: 300.ms);
  }
}

class _StatItemWidget extends StatelessWidget {
  const _StatItemWidget({
    required this.label,
    required this.animationDelay,
    required this.value,
    required this.isVisible,
  });

  final bool isVisible;
  final Duration animationDelay;
  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DSTextWidget(
          '$value+',
          style: context.typography.emphasizedTitleLarge,
          color: context.isDesktop
              ? context.colorPalette.neutral.grey4
              : context.colorPalette.neutral.grey9,
        ),
        DSTextWidget(
          label,
          style: context.typography.emphasizedLabelSmall,
          color: context.isDesktop
              ? context.colorPalette.neutral.grey5
              : context.colorPalette.neutral.grey7,
        ),
      ],
    );
  }
}
