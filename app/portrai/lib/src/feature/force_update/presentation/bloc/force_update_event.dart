import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ForceUpdateEvent extends Equatable {
  const ForceUpdateEvent();

  @override
  List<Object> get props => [];
}

class CheckForceUpdateEvent extends ForceUpdateEvent {
  const CheckForceUpdateEvent();
}

class UpdateNowClickEvent extends ForceUpdateEvent {
  const UpdateNowClickEvent();
}

/// Fired when the bottom sheet actually becomes visible to the user (see
/// [TrackingImpressionDetectorWidget] in [ForceUpdateBottomSheetWidget]).
class BottomSheetVisibleEvent extends ForceUpdateEvent {
  const BottomSheetVisibleEvent();
}
