import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class AvailabilityMapper
    implements BiMapper<AvailabilityModel, AvailabilityEntity> {
  const AvailabilityMapper();

  @override
  AvailabilityModel from(AvailabilityEntity entity) {
    return AvailabilityModel(
      status: entity.status,
      workType: entity.workType,
      openToRelocate: entity.openToRelocate,
      preferredProjectDuration: entity.preferredProjectDuration,
      hourlyRate: entity.hourlyRate,
      availability: entity.availability,
    );
  }

  @override
  AvailabilityEntity to(AvailabilityModel model) {
    return AvailabilityEntity(
      status: model.status,
      workType: model.workType,
      openToRelocate: model.openToRelocate,
      preferredProjectDuration: model.preferredProjectDuration,
      hourlyRate: model.hourlyRate,
      availability: model.availability,
    );
  }
}
