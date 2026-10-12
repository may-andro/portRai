import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('remote_assistant');
}

@register
class RemoteAssistantTrackingDelegate extends ScreenTrackingDelegate {
  RemoteAssistantTrackingDelegate(TrackingReporter reporter)
    : super(const _TrackingArea(), reporter);

  void trackQuestionSubmission() => trackEvent(
    Tracking(
      name: 'question',
      action: const ClickAction(label: 'submit'),
    ),
  );

  void trackSuggestionClick() => trackEvent(
    Tracking(
      name: 'question',
      action: const ClickAction(label: 'suggestion'),
    ),
  );

  void trackLinkClick() => trackEvent(
    Tracking(
      name: 'external_link',
      action: const ClickAction(label: 'generated_link'),
    ),
  );

  void trackReset() => trackEvent(
    Tracking(
      name: 'reset',
      action: const ClickAction(label: 'reset'),
    ),
  );
}
