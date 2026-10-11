import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('remote_assistant');
}

@register
class RemoteAssistantTrackingDelegate extends ScreenTrackingDelegate {
  RemoteAssistantTrackingDelegate(TrackingReporter reporter)
    : super(const _TrackingArea(), reporter);

  void trackConsentAcceptance() => trackEvent(
    Tracking(
      name: 'consent',
      action: const ClickAction(label: 'accept'),
    ),
  );

  void trackQuestionSubmission() => trackEvent(
    Tracking(
      name: 'question',
      action: const ClickAction(label: 'submit'),
    ),
  );

  void trackDisable() => trackEvent(
    Tracking(
      name: 'disable',
      action: const ClickAction(label: 'disable'),
    ),
  );

  void trackReset() => trackEvent(
    Tracking(
      name: 'reset',
      action: const ClickAction(label: 'reset'),
    ),
  );
}
