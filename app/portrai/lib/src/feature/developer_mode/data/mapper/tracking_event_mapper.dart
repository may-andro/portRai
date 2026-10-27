import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:tracking/tracking.dart';

/// Maps a kept [SentTracking] to an entity. Only this direction exists, since
/// the viewer never sends events.
@register
class TrackingEventMapper implements Mapper<SentTracking, TrackingEventEntity> {
  const TrackingEventMapper();

  @override
  TrackingEventEntity map(SentTracking from) {
    final tracking = from.tracking;
    return TrackingEventEntity(
      id: '${from.sequenceNumber}',
      sentAt: from.sentAt,
      name: tracking.name,
      area: tracking.area,
      actionType: tracking.action?.action,
      parameters: tracking.parameters.map(
        (key, parameter) => MapEntry(key, '$parameter'),
      ),
    );
  }
}
