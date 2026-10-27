import 'package:flutter_test/flutter_test.dart';
import 'package:tracking/src/area_controller/area_controller.dart';
import 'package:tracking/src/model/model.dart';

class _OtherArea extends TrackingArea {
  const _OtherArea() : super('other');
}

class _NextArea extends TrackingArea {
  const _NextArea() : super('next');
}

void main() {
  setUp(() => TrackingAreaController().currentArea = const _OtherArea());

  group('ScreenViewTracking', () {
    test('should be sent from the screen it enters when created', () {
      final tracking = ScreenViewTracking(area: const _NextArea());

      expect(tracking.area, 'next');
      expect(tracking.parameters['area'], 'next');
      expect(TrackingAreaController().currentArea, const _NextArea());
    });

    test('should send the following events from the screen it enters when '
        'created', () {
      ScreenViewTracking(area: const _NextArea());

      expect(ViewTracking(label: 'loaded_content_view').area, 'next');
    });
  });

  group('AppStartTracking', () {
    test('should be sent from the splash area when created', () {
      final tracking = AppStartTracking();

      expect(tracking.area, 'splash');
      expect(tracking.parameters['area'], 'splash');
    });
  });

  group('Tracking', () {
    test('should be sent from the current area when created', () {
      final tracking = ClickTracking(label: 'header_tab');

      expect(tracking.area, 'other');
      expect(tracking.parameters['area'], 'other');
    });
  });
}
