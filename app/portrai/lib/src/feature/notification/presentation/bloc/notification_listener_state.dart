import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

/// One-off effects for the listener widget. [sequence] makes two equal
/// messages in a row distinct states.
sealed class NotificationListenerState extends Equatable {
  const NotificationListenerState();

  @override
  List<Object?> get props => [];
}

class NotificationListenerIdleState extends NotificationListenerState {
  const NotificationListenerIdleState();
}

/// The user tapped the notification of [message].
class PushMessageOpenedState extends NotificationListenerState {
  const PushMessageOpenedState(this.message, this.sequence);

  final PushMessageEntity message;
  final int sequence;

  @override
  List<Object?> get props => [message, sequence];
}

/// [message] arrived while the app is in the foreground.
class PushMessageReceivedState extends NotificationListenerState {
  const PushMessageReceivedState(this.message, this.sequence);

  final PushMessageEntity message;
  final int sequence;

  @override
  List<Object?> get props => [message, sequence];
}
