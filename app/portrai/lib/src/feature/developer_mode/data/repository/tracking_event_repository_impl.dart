import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';
import 'package:tracking/tracking.dart';

@Register(as: TrackingEventRepository)
class TrackingEventRepositoryImpl implements TrackingEventRepository {
  TrackingEventRepositoryImpl(this._trackingReporter, this._mapper);

  final TrackingReporter _trackingReporter;
  final TrackingEventMapper _mapper;

  @override
  List<TrackingEventEntity>? getSentTrackingEvents() =>
      _trackingReporter.sentTrackingEvents?.map(_mapper.map).toList();
}
