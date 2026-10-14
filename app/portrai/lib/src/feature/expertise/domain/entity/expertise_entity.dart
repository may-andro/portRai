import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';

class ExpertiseEntity extends Equatable {
  const ExpertiseEntity({
    required this.image,
    required this.title,
    required this.skills,
    this.summary,
  });

  final String image;
  final String title;
  final List<SkillEntity> skills;

  /// Short description of what this expertise covers.
  final String? summary;

  List<String> get skillNames => [for (final skill in skills) skill.name];

  int get expertSkillCount {
    return skills.where((skill) => skill.level == 'expert').length;
  }

  /// Longest hands-on experience across the skills, if any is known.
  int? get maxYears {
    final years = [
      for (final skill in skills)
        if (skill.years != null) skill.years!,
    ];
    return years.isEmpty ? null : years.reduce((a, b) => a > b ? a : b);
  }

  /// Most recent year any of the skills was used, if any is known.
  int? get latestYearUsed {
    final years = [
      for (final skill in skills)
        if (skill.lastUsed != null) skill.lastUsed!,
    ];
    return years.isEmpty ? null : years.reduce((a, b) => a > b ? a : b);
  }

  @override
  List<Object?> get props => [image, title, skills, summary];
}
