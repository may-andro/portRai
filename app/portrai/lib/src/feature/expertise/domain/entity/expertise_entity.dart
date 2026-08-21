import 'package:equatable/equatable.dart';

class ExpertiseEntity extends Equatable {
  const ExpertiseEntity({
    required this.image,
    required this.title,
    required this.skills,
  });

  final String image;
  final String title;
  final List<String> skills;

  @override
  List<Object?> get props => [image, title, skills];
}
