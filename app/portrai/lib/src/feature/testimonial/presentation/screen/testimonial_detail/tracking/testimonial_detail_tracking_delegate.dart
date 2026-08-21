import 'package:module_injector/module_injector.dart';
import 'package:tracking/tracking.dart';

class _TrackingArea extends TrackingArea {
  const _TrackingArea() : super('testimonial_detail');
}

@register
class TestimonialDetailTrackingDelegate extends ScreenTrackingDelegate {
  TestimonialDetailTrackingDelegate(TrackingReporter trackingReporter)
    : super(const _TrackingArea(), trackingReporter);
}
