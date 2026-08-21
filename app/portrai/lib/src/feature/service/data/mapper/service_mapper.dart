import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/service/data/model/_model.dart';
import 'package:portrai/src/feature/service/domain/_domain.dart';

@register
class ServiceMapper implements BiMapper<ServiceModel, ServiceEntity> {
  const ServiceMapper({required this.appLocale});

  final AppLocale appLocale;

  @override
  ServiceModel from(ServiceEntity entity) {
    return ServiceModel(
      title: entity.title,
      description: entity.description,
      image: entity.image,
      detail: entity.detail,
      locale: appLocale.languageCode,
    );
  }

  @override
  ServiceEntity to(ServiceModel model) {
    return ServiceEntity(
      title: model.title,
      description: model.description,
      image: model.image,
      detail: model.detail,
    );
  }
}
