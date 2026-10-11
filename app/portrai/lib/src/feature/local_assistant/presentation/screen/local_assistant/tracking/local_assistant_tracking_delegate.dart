import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _LocalAssistantTrackingArea extends TrackingArea {
  const _LocalAssistantTrackingArea() : super('assistant');
}

@register
class LocalAssistantTrackingDelegate extends ScreenTrackingDelegate {
  LocalAssistantTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _LocalAssistantTrackingArea(), trackingReporter);

  void trackQuestionSubmission() {
    trackEvent(
      Tracking(
        name: 'assistant_question',
        action: const ClickAction(label: 'submit'),
      ),
    );
  }

  void trackReset() {
    trackEvent(
      Tracking(
        name: 'assistant_reset',
        action: const ClickAction(label: 'reset'),
      ),
    );
  }
}
