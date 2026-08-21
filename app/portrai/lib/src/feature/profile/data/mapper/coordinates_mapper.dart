import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class CoordinatesMapper
    implements BiMapper<CoordinatesModel, CoordinatesEntity> {
  const CoordinatesMapper();

  @override
  CoordinatesModel from(CoordinatesEntity entity) {
    return CoordinatesModel(
      latitude: entity.latitude,
      longitude: entity.longitude,
    );
  }

  @override
  CoordinatesEntity to(CoordinatesModel model) {
    return CoordinatesEntity(
      latitude: model.latitude,
      longitude: model.longitude,
    );
  }
}
