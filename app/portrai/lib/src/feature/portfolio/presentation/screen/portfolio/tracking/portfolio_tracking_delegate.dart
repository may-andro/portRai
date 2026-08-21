import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('portfolio');
}

@register
class PortfolioTrackingDelegate extends ScreenTrackingDelegate {
  PortfolioTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);

  void trackViewEvent(String label) {
    trackEvent(ViewTracking(label: label));
  }

  void trackDrawerOpen() {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: const ViewAction(label: 'open'),
      ),
    );
  }

  void trackDrawerClose() {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: const ViewAction(label: 'close'),
      ),
    );
  }

  void trackDrawerItemSelection(String drawerItemName) {
    trackEvent(
      Tracking(
        name: 'drawer_menu',
        action: ClickAction(label: drawerItemName),
      ),
    );
  }

  void trackTabItemSelection(String drawerItemName) {
    trackEvent(
      Tracking(
        name: 'header_tab',
        action: ClickAction(label: drawerItemName),
      ),
    );
  }
}
