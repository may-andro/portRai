import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class LanguageMapper implements BiMapper<LanguageModel, LanguageEntity> {
  const LanguageMapper();

  @override
  LanguageModel from(LanguageEntity entity) {
    return LanguageModel(
      language: entity.language,
      proficiency: entity.proficiency,
    );
  }

  @override
  LanguageEntity to(LanguageModel model) {
    return LanguageEntity(
      language: model.language,
      proficiency: model.proficiency,
    );
  }
}
