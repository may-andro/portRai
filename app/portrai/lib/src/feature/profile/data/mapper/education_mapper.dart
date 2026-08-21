import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/education_model.dart';
import 'package:portrai/src/feature/profile/domain/entity/education_entity.dart';

@register
class EducationMapper implements BiMapper<EducationModel, EducationEntity> {
  const EducationMapper();

  @override
  EducationModel from(EducationEntity entity) => EducationModel(
    institution: entity.institution,
    degree: entity.degree,
    field: entity.field,
    startDate: entity.startDate,
    endDate: entity.endDate,
    image: entity.image,
    url: entity.url,
    location: entity.location,
  );

  @override
  EducationEntity to(EducationModel model) => EducationEntity(
    institution: model.institution,
    degree: model.degree,
    field: model.field,
    startDate: model.startDate,
    endDate: model.endDate,
    image: model.image,
    url: model.url,
    location: model.location,
  );
}
