import 'package:portrai/src/feature/developer_mode/domain/entity/_entity.dart';

abstract interface class TrackingEventRepository {
  /// The events sent in this session in the order they were sent, oldest
  /// first, or `null` when sent events are not kept.
  List<TrackingEventEntity>? getSentTrackingEvents();
}
