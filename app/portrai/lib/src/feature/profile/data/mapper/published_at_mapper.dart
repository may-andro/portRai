import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class PublishedAtMapper
    implements BiMapper<PublishedAtModel, PublishedAtEntity> {
  const PublishedAtMapper();

  @override
  PublishedAtModel from(PublishedAtEntity entity) {
    return PublishedAtModel(
      name: entity.name,
      url: entity.url,
      image: entity.image,
    );
  }

  @override
  PublishedAtEntity to(PublishedAtModel model) {
    return PublishedAtEntity(
      name: model.name,
      url: model.url,
      image: model.image,
    );
  }
}
