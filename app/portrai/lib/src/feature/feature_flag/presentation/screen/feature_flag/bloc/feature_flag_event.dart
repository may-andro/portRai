import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';

@immutable
abstract class FeatureFlagEvent extends Equatable {
  const FeatureFlagEvent();

  @override
  List<Object?> get props => [];
}

class LoadFeatureFlagEvent extends FeatureFlagEvent {
  const LoadFeatureFlagEvent();
}

class ToggleFeatureFlagEvent extends FeatureFlagEvent {
  const ToggleFeatureFlagEvent(this.flag);

  final AppFeatureFlagEntity flag;

  @override
  List<Object?> get props => [flag];
}

class ResetAllFeatureFlagsEvent extends FeatureFlagEvent {
  const ResetAllFeatureFlagsEvent();
}

class SearchFeatureFlagsEvent extends FeatureFlagEvent {
  const SearchFeatureFlagsEvent(this.query);

  final String query;

  @override
  List<Object?> get props => [query];
}

class ToggleViewModeEvent extends FeatureFlagEvent {
  const ToggleViewModeEvent();
}

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
