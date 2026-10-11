import 'package:equatable/equatable.dart';

sealed class RemoteAssistantEvent extends Equatable {
  const RemoteAssistantEvent();

  @override
  List<Object?> get props => [];
}

class RemoteAssistantStartedEvent extends RemoteAssistantEvent {
  const RemoteAssistantStartedEvent();
}

class RemoteAssistantInitializedEvent extends RemoteAssistantEvent {
  const RemoteAssistantInitializedEvent();
}

class AcceptRemoteAssistantConsentClickEvent extends RemoteAssistantEvent {
  const AcceptRemoteAssistantConsentClickEvent();
}

class DisableRemoteAssistantClickEvent extends RemoteAssistantEvent {
  const DisableRemoteAssistantClickEvent();
}

class ResetRemoteAssistantClickEvent extends RemoteAssistantEvent {
  const ResetRemoteAssistantClickEvent();
}

class SendRemoteAssistantQuestionClickEvent extends RemoteAssistantEvent {
  const SendRemoteAssistantQuestionClickEvent(this.question);

  final String question;

  @override
  List<Object?> get props => [question];

  @override
  String toString() => 'SendRemoteAssistantQuestionClickEvent';
}

class RemoteAssistantFlagsChangedEvent extends RemoteAssistantEvent {
  const RemoteAssistantFlagsChangedEvent();
}
