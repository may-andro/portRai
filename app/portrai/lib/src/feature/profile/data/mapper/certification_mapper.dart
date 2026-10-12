import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/certification_model.dart';
import 'package:portrai/src/feature/profile/domain/entity/certification_entity.dart';

@register
class CertificationMapper
    implements BiMapper<CertificationModel, CertificationEntity> {
  const CertificationMapper();

  @override
  CertificationModel from(CertificationEntity entity) => CertificationModel(
    name: entity.name,
    issuer: entity.issuer,
    date: entity.date,
    url: entity.url,
  );

  @override
  CertificationEntity to(CertificationModel model) => CertificationEntity(
    name: model.name,
    issuer: model.issuer,
    date: model.date,
    url: model.url,
  );
}
