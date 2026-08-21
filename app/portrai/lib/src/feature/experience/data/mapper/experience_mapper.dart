import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/experience/data/model/_model.dart';
import 'package:portrai/src/feature/experience/domain/_domain.dart';

@register
class ExperienceMapper implements BiMapper<ExperienceModel, ExperienceEntity> {
  const ExperienceMapper({required this.appLocale});

  final AppLocale appLocale;

  @override
  ExperienceModel from(ExperienceEntity entity) => ExperienceModel(
    company: entity.company,
    position: entity.position,
    location: entity.location,
    startDate: entity.startDate.toFormattedDate,
    endDate: entity.endDate?.toFormattedDate,
    current: entity.current,
    employmentType: entity.employmentType,
    longDescription: entity.longDescription,
    description: entity.description,
    responsibilities: entity.responsibilities,
    achievements: entity.achievements,
    technologies: entity.technologies,
    companyLogo: entity.companyLogo,
    id: entity.id,
    url: entity.url,
    locale: appLocale.languageCode,
  );

  @override
  ExperienceEntity to(ExperienceModel model) => ExperienceEntity(
    company: model.company,
    position: model.position,
    location: model.location,
    startDate: model.startDate.toFormattedDate,
    endDate: model.endDate?.toFormattedDate,
    current: model.current,
    employmentType: model.employmentType,
    description: model.description,
    longDescription: model.longDescription,
    responsibilities: model.responsibilities,
    achievements: model.achievements,
    technologies: model.technologies,
    companyLogo: model.companyLogo,
    id: model.id,
    url: model.url,
  );
}
