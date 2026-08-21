import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class ResumeMapper implements BiMapper<ResumeModel, ResumeEntity> {
  const ResumeMapper();

  @override
  ResumeModel from(ResumeEntity entity) {
    return ResumeModel(
      url: entity.url,
      lastUpdated: entity.lastUpdated,
      image: entity.image,
    );
  }

  @override
  ResumeEntity to(ResumeModel model) {
    return ResumeEntity(
      url: model.url,
      lastUpdated: model.lastUpdated,
      image: model.image,
    );
  }
}
