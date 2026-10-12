import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/expertise/domain/entity/skill_entity.dart';

class ExpertiseEntity extends Equatable {
  const ExpertiseEntity({
    required this.image,
    required this.title,
    required this.skills,
  });

  final String image;
  final String title;
  final List<SkillEntity> skills;

  List<String> get skillNames => [for (final skill in skills) skill.name];

  @override
  List<Object?> get props => [image, title, skills];
}
