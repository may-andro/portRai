import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class DeveloperMenuEvent extends Equatable {
  const DeveloperMenuEvent();

  @override
  List<Object?> get props => [];
}

class LoadDeveloperMenuEvent extends DeveloperMenuEvent {
  const LoadDeveloperMenuEvent();
}

class ForceFatalCrashEvent extends DeveloperMenuEvent {
  const ForceFatalCrashEvent();
}

class ForceNonFatalCrashEvent extends DeveloperMenuEvent {
  const ForceNonFatalCrashEvent();
}

class ForceBlacklistErrorEvent extends DeveloperMenuEvent {
  const ForceBlacklistErrorEvent();
}

// Tracking Events
final class ScreenVisibleEvent extends DeveloperMenuEvent {
  const ScreenVisibleEvent();
}

final class ViewStateVisibleEvent extends DeveloperMenuEvent {
  const ViewStateVisibleEvent(this.trackingId);

  factory ViewStateVisibleEvent.loading() {
    return const ViewStateVisibleEvent('developer_menu_loading_content_view');
  }

  factory ViewStateVisibleEvent.success() {
    return const ViewStateVisibleEvent('developer_menu_loaded_content_view');
  }

  factory ViewStateVisibleEvent.error() {
    return const ViewStateVisibleEvent('developer_menu_error_content_view');
  }

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
