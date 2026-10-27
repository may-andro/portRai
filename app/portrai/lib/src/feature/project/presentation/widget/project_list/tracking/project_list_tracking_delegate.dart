import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

@register
class ProjectListTrackingDelegate extends TrackingDelegate {
  ProjectListTrackingDelegate(super.trackingReporter);

  void trackProjectClick({required String label, required String projectId}) {
    trackEvent(
      Tracking(
        name: 'project',
        action: ClickAction(label: label, value: projectId),
      ),
    );
  }
}
