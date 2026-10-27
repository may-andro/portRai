import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/developer_mode/data/_data.dart';
import 'package:tracking/tracking.dart';

void main() {
  group('TrackingEventMapper', () {
    const mapper = TrackingEventMapper();
    final sentAt = DateTime(2026, 10, 27, 14, 5, 9, 42);

    test('should map the sent parameters, send time and sequence number when '
        'the event has an action', () {
      final tracking = ClickTracking(label: 'header_tab', value: 'skills');

      final trackingEvent = mapper.map(
        SentTracking(sequenceNumber: 12, sentAt: sentAt, tracking: tracking),
      );

      expect(trackingEvent.id, '12');
      expect(trackingEvent.sentAt, sentAt);
      expect(trackingEvent.name, 'click');
      expect(trackingEvent.area, tracking.area);
      expect(trackingEvent.actionType, 'click');
      expect(trackingEvent.parameters, {
        'event': 'click',
        'area': tracking.area,
        'action': 'click',
        'label': 'header_tab',
        'value': 'skills',
      });
    });

    test('should leave the action type empty when the event has no action', () {
      final tracking = Tracking(name: 'custom', action: null);

      final trackingEvent = mapper.map(
        SentTracking(sequenceNumber: 0, sentAt: sentAt, tracking: tracking),
      );

      expect(trackingEvent.actionType, isNull);
      expect(trackingEvent.parameters, {
        'event': 'custom',
        'area': tracking.area,
      });
    });
  });
}
