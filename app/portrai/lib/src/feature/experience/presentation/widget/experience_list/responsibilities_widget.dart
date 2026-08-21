part of 'experience_list_widget.dart';

class _ResponsibilitiesWidget extends StatelessWidget {
  const _ResponsibilitiesWidget({
    required this.responsibilities,
    required this.isVisible,
  });

  final List<String> responsibilities;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: responsibilities.length,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: context.space()),
      shrinkWrap: true,
      separatorBuilder: (_, index) {
        return const DSVerticalSpacerWidget(0.5);
      },
      itemBuilder: (context, index) {
        final responsibility = responsibilities[index];
        return DSTextWidget(
              '${index + 1}. $responsibility',
              color: context.colorPalette.neutral.grey8,
              style: context.typography.labelMedium,
            )
            .animate(target: isVisible ? 1 : 0)
            .slideY(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      },
    );
  }
}
