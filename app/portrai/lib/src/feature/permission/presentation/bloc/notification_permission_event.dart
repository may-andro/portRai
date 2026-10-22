import 'package:equatable/equatable.dart';

sealed class NotificationPermissionEvent extends Equatable {
  const NotificationPermissionEvent();

  @override
  List<Object?> get props => [];
}

/// The setting became visible, including on return from the device
/// settings, so the system status is read again.
class NotificationPermissionVisibleEvent extends NotificationPermissionEvent {
  const NotificationPermissionVisibleEvent();
}

class NotificationPermissionToggleClickEvent
    extends NotificationPermissionEvent {
  const NotificationPermissionToggleClickEvent({required this.enabled});

  final bool enabled;

  @override
  List<Object?> get props => [enabled];
}
