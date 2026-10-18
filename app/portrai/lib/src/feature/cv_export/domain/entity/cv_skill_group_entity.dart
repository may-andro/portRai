import 'package:equatable/equatable.dart';

class CvSkillGroupEntity extends Equatable {
  const CvSkillGroupEntity({required this.title, required this.skills});

  final String title;
  final List<String> skills;

  @override
  List<Object?> get props => [title, skills];
}
