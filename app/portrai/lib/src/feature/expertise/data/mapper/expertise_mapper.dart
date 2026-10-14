import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/expertise/data/model/_model.dart';
import 'package:portrai/src/feature/expertise/domain/_domain.dart';

@register
class ExpertiseMapper implements BiMapper<ExpertiseModel, ExpertiseEntity> {
  const ExpertiseMapper({required this.appLocale});

  final AppLocale appLocale;

  @override
  ExpertiseModel from(ExpertiseEntity entity) {
    return ExpertiseModel(
      image: entity.image,
      title: entity.title,
      skills: [
        for (final skill in entity.skills)
          SkillModel(
            name: skill.name,
            description: skill.description,
            level: skill.level,
            years: skill.years,
            lastUsed: skill.lastUsed,
          ),
      ],
      locale: appLocale.languageCode,
      summary: entity.summary,
    );
  }

  @override
  ExpertiseEntity to(ExpertiseModel model) {
    return ExpertiseEntity(
      image: model.image,
      title: model.title,
      skills: [
        for (final skill in model.skills)
          SkillEntity(
            name: skill.name,
            description: skill.description,
            level: skill.level,
            years: skill.years,
            lastUsed: skill.lastUsed,
          ),
      ],
      summary: model.summary,
    );
  }
}
