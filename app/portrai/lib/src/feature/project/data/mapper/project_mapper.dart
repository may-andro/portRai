import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/data/model/_model.dart';
import 'package:portrai/src/feature/project/domain/_domain.dart';

@register
class ProjectMapper implements BiMapper<ProjectModel, ProjectEntity> {
  const ProjectMapper({required this.appLocale});

  final AppLocale appLocale;

  @override
  ProjectModel from(ProjectEntity entity) {
    return ProjectModel(
      title: entity.title,
      description: entity.description,
      longDescription: entity.longDescription,
      technologies: entity.technologies,
      category: entity.category,
      status: entity.status,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      image: entity.image,
      appStore: entity.appStore,
      playStore: entity.playStore,
      website: entity.website,
      github: entity.github,
      features: entity.features,
      achievements: entity.achievements,
      teamSize: entity.teamSize,
      role: entity.role,
      id: entity.id,
      locale: appLocale.languageCode,
    );
  }

  @override
  ProjectEntity to(ProjectModel model) {
    return ProjectEntity(
      title: model.title,
      description: model.description,
      longDescription: model.longDescription,
      technologies: model.technologies,
      category: model.category,
      status: model.status,
      startDate: DateTime.parse(model.startDate),
      endDate: model.endDate != null ? DateTime.parse(model.endDate!) : null,
      image: model.image,
      appStore: model.appStore,
      playStore: model.playStore,
      website: model.website,
      github: model.github,
      features: model.features,
      achievements: model.achievements,
      teamSize: model.teamSize,
      role: model.role,
      id: model.id,
    );
  }
}
