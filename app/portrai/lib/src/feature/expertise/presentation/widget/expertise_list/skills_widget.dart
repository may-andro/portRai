part of 'expertise_list_widget.dart';

class _SkillsWidget extends StatelessWidget {
  const _SkillsWidget({
    required this.skills,
    this.alignment = WrapAlignment.start,
  });

  final List<String> skills;
  final WrapAlignment alignment;

  static double getHeight(BuildContext context, int maxVerticalLines) {
    return (context.space(factor: 0.5) + DSTagWidget.getHeight(context)) *
        maxVerticalLines;
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: context.space(factor: 0.5),
      runSpacing: context.space(factor: 0.5),
      alignment: alignment,
      children: skills.mapIndexed((index, skill) {
        return DSTagWidget(label: skill);
      }).toList(),
    );
  }
}
