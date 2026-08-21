import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/profile/data/model/_model.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';

@register
class WorkingHoursMapper
    implements BiMapper<WorkingHoursModel, WorkingHoursEntity> {
  const WorkingHoursMapper();

  @override
  WorkingHoursModel from(WorkingHoursEntity entity) {
    return WorkingHoursModel(
      timezone: entity.timezone,
      preferredHours: entity.preferredHours,
      weekdays: entity.weekdays,
      weekends: entity.weekends,
    );
  }

  @override
  WorkingHoursEntity to(WorkingHoursModel model) {
    return WorkingHoursEntity(
      timezone: model.timezone,
      preferredHours: model.preferredHours,
      weekdays: model.weekdays,
      weekends: model.weekends,
    );
  }
}
