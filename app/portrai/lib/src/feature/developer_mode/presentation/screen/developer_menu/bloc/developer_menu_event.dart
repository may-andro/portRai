import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/ai_image_gen/ai_image_gen.dart';
import 'package:portrai/src/feature/asset_source/asset_source.dart';

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

class AssetSourceClickEvent extends DeveloperMenuEvent {
  const AssetSourceClickEvent(this.source);

  final AssetSource source;

  @override
  List<Object?> get props => [source];
}

class AiImageStyleClickEvent extends DeveloperMenuEvent {
  const AiImageStyleClickEvent(this.style);

  final AiImageStyle style;

  @override
  List<Object?> get props => [style];
}

class AiImageModelClickEvent extends DeveloperMenuEvent {
  const AiImageModelClickEvent(this.model);

  final AiImageModelType model;

  @override
  List<Object?> get props => [model];
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
