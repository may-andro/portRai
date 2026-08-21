part of 'experience_list_widget.dart';

class _TechnologiesWidget extends StatelessWidget {
  const _TechnologiesWidget({
    required this.technologies,
    required this.isVisible,
  });

  final List<String> technologies;
  final bool isVisible;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: 0.5),
      runSpacing: context.space(factor: 0.5),
      children: technologies.mapIndexed((index, technology) {
        return DSTagWidget(label: technology)
            .animate(target: isVisible ? 1 : 0)
            .slideX(
              begin: 1 + (index * 0.2),
              duration: 300.ms,
              delay: (100 + index * 100).ms,
              curve: Curves.easeOut,
            )
            .fadeIn(delay: (300 + index * 100).ms, duration: 300.ms);
      }).toList(),
    );
  }
}
