import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ProjectListTrackingDelegate extends TrackingDelegate {
  ProjectListTrackingDelegate(super.trackingReporter);

  void trackProjectClick(String projectId) {
    trackEvent(
      Tracking(
        name: 'project',
        action: ClickAction(label: projectId),
      ),
    );
  }
}
