import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('setting');
}

@register
class SettingTrackingDelegate extends ScreenTrackingDelegate {
  SettingTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackEntryClick(String label) {
    trackEvent(
      Tracking(
        name: 'setting_entry',
        action: ClickAction(label: label),
      ),
    );
  }
}
