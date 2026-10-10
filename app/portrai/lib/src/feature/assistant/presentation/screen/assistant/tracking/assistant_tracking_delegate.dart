import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _AssistantTrackingArea extends TrackingArea {
  const _AssistantTrackingArea() : super('assistant');
}

@register
class AssistantTrackingDelegate extends ScreenTrackingDelegate {
  AssistantTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _AssistantTrackingArea(), trackingReporter);

  void trackQuestionSubmission() {
    trackEvent(
      Tracking(
        name: 'assistant_question',
        action: const ClickAction(label: 'submit'),
      ),
    );
  }
}
