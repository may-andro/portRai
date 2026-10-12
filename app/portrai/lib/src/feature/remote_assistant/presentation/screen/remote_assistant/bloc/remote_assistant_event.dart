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

class ResetRemoteAssistantClickEvent extends RemoteAssistantEvent {
  const ResetRemoteAssistantClickEvent();
}

class OpenRemoteAssistantLinkClickEvent extends RemoteAssistantEvent {
  const OpenRemoteAssistantLinkClickEvent(this.url);

  final String url;

  @override
  List<Object?> get props => [url];

  @override
  String toString() => 'OpenRemoteAssistantLinkClickEvent';
}

class SendRemoteAssistantQuestionClickEvent extends RemoteAssistantEvent {
  const SendRemoteAssistantQuestionClickEvent(
    this.question, {
    this.isSuggestion = false,
  });

  final String question;
  final bool isSuggestion;

  @override
  List<Object?> get props => [question, isSuggestion];

  @override
  String toString() => 'SendRemoteAssistantQuestionClickEvent';
}
