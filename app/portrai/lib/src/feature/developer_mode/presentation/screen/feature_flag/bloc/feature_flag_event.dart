import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class FeatureFlagEvent extends Equatable {
  const FeatureFlagEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatureFlagEvent extends FeatureFlagEvent {
  const LoadFeatureFlagEvent();
}

// Tracking Events
final class ScreenVisibleEvent extends FeatureFlagEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends FeatureFlagEvent {
  const ViewStateVisibleEvent(this.trackingId);

  factory ViewStateVisibleEvent.loading() {
    return const ViewStateVisibleEvent('feature_flag_loading_content_view');
  }

  factory ViewStateVisibleEvent.success() {
    return const ViewStateVisibleEvent('feature_flag_loaded_content_view');
  }

  factory ViewStateVisibleEvent.error() {
    return const ViewStateVisibleEvent('feature_flag_error_content_view');
  }

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
