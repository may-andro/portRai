import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class SocialLinkMapper implements BiMapper<SocialLinkModel, SocialLinkEntity> {
  const SocialLinkMapper();

  @override
  SocialLinkModel from(SocialLinkEntity entity) {
    return SocialLinkModel(
      name: entity.name,
      url: entity.url,
      image: entity.image,
    );
  }

  @override
  SocialLinkEntity to(SocialLinkModel model) {
    return SocialLinkEntity(
      name: model.name,
      url: model.url,
      image: model.image,
    );
  }
}
