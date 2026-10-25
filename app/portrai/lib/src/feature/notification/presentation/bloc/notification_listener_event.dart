import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

sealed class NotificationListenerEvent extends Equatable {
  const NotificationListenerEvent();

  @override
  List<Object?> get props => [];
}

/// The app started. [supportedLanguageCodes] are the languages it offers.
class NotificationListenerStartEvent extends NotificationListenerEvent {
  const NotificationListenerStartEvent(this.supportedLanguageCodes);

  final List<String> supportedLanguageCodes;

  @override
  List<Object?> get props => [supportedLanguageCodes];
}

/// Something the notifications depend on may have changed, such as the
/// permission while the app was in the background, the language or the token.
class NotificationsSyncRequestedEvent extends NotificationListenerEvent {
  const NotificationsSyncRequestedEvent();
}

class SignedInStatusChangedEvent extends NotificationListenerEvent {
  const SignedInStatusChangedEvent({required this.isSignedIn});

  final bool isSignedIn;

  @override
  List<Object?> get props => [isSignedIn];
}

class PushMessageOpenedEvent extends NotificationListenerEvent {
  const PushMessageOpenedEvent(this.message);

  final PushMessageEntity message;

  @override
  List<Object?> get props => [message];
}

class PushMessageReceivedEvent extends NotificationListenerEvent {
  const PushMessageReceivedEvent(this.message);

  final PushMessageEntity message;

  @override
  List<Object?> get props => [message];
}
