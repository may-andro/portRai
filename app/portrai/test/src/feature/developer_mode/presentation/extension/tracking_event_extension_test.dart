import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/developer_mode/presentation/extension/_extension.dart';

import '../../../../../mock/feature/developer_mode/domain/entity/tracking_event_entity_fixture.dart';

void main() {
  group('TrackingEventExtension', () {
    test('should format the send time to the millisecond when formatted', () {
      expect(trackingEventEntityFixture().formattedSentAt, '14:05:09.042');
    });

    test('should leave out the name, area and action when summarizing', () {
      final trackingEvent = trackingEventEntityFixture(
        parameters: {
          'event': 'click',
          'area': 'experience',
          'action': 'click',
          'label': 'header_tab',
          'value': 'skills',
        },
      );

      expect(
        trackingEvent.parameterSummary,
        'label: header_tab · value: skills',
      );
    });

    test('should encode the parameters as indented JSON when building the '
        'payload', () {
      final trackingEvent = trackingEventEntityFixture(
        parameters: {'event': 'click', 'label': 'header_tab'},
      );

      expect(
        trackingEvent.payload,
        '{\n  "event": "click",\n  "label": "header_tab"\n}',
      );
    });

    test('should pick the icon from the action type when shown', () {
      expect(trackingEventEntityFixture().icon, Icons.touch_app_outlined);
      expect(
        trackingEventEntityFixture(actionType: null).icon,
        Icons.web_asset_outlined,
      );
    });
  });
}
