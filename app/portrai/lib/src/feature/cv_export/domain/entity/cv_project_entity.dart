import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/cv_export/domain/entity/cv_project_link_entity.dart';

class CvProjectEntity extends Equatable {
  const CvProjectEntity({
    required this.title,
    required this.role,
    required this.description,
    required this.technologies,
    this.links = const [],
  });

  final String title;
  final String role;
  final String description;
  final List<String> technologies;

  /// Website and store listings, the first one is the primary link.
  final List<CvProjectLinkEntity> links;

  @override
  List<Object?> get props => [title, role, description, technologies, links];
}
