import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/mapper/coordinates_mapper.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class LocationMapper implements BiMapper<LocationModel, LocationEntity> {
  const LocationMapper({required this.coordinatesMapper});

  final CoordinatesMapper coordinatesMapper;

  @override
  LocationModel from(LocationEntity entity) {
    return LocationModel(
      city: entity.city,
      state: entity.state,
      country: entity.country,
      timezone: entity.timezone,
      coordinates: coordinatesMapper.from(entity.coordinates),
    );
  }

  @override
  LocationEntity to(LocationModel model) {
    return LocationEntity(
      city: model.city,
      state: model.state,
      country: model.country,
      timezone: model.timezone,
      coordinates: coordinatesMapper.to(model.coordinates),
    );
  }
}
