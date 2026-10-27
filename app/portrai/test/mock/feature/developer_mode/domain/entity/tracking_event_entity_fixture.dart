import 'package:portrai/src/feature/developer_mode/domain/_domain.dart';

TrackingEventEntity trackingEventEntityFixture({
  String id = '1',
  DateTime? sentAt,
  String name = 'click',
  String area = 'experience',
  String? actionType = 'click',
  Map<String, String>? parameters,
}) => TrackingEventEntity(
  id: id,
  sentAt: sentAt ?? DateTime(2026, 10, 27, 14, 5, 9, 42),
  name: name,
  area: area,
  actionType: actionType,
  parameters:
      parameters ??
      {
        'event': name,
        'area': area,
        'action': ?actionType,
        'label': 'header_tab',
      },
);
