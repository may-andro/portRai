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

    return Wrap(
          spacing: context.space(factor: 3),
          runSpacing: context.space(factor: 1.5),
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
    return DSHoverableContainerWidget(
      builder: (context, isHovering) {
        return AnimatedScale(
          duration: 200.ms,
          curve: Curves.easeOutBack,
          alignment: Alignment.centerLeft,
          scale: isHovering ? 1.1 : 1,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: context.space(factor: 20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DSTextWidget(
                  '$value+',
                  style: context.typography.emphasizedTitleLarge,
                  color: isHovering
                      ? context.colorPalette.brand.primary
                      : context.colorPalette.surface.onSurface,
                ),
                DSTextWidget(
                  label,
                  style: context.typography.emphasizedLabelSmall,
                  color: context.colorPalette.neutral.grey7,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
