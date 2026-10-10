import 'package:equatable/equatable.dart';

sealed class AssistantEvent extends Equatable {
  const AssistantEvent();

  @override
  List<Object?> get props => [];
}

class AssistantStartedEvent extends AssistantEvent {
  const AssistantStartedEvent();
}

class AssistantInitializedEvent extends AssistantEvent {
  const AssistantInitializedEvent();
}

class EnableAssistantClickEvent extends AssistantEvent {
  const EnableAssistantClickEvent();
}

class DisableAssistantClickEvent extends AssistantEvent {
  const DisableAssistantClickEvent({required this.deleteModel});

  final bool deleteModel;

  @override
  List<Object?> get props => [deleteModel];
}

class SendAssistantQuestionClickEvent extends AssistantEvent {
  const SendAssistantQuestionClickEvent(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}
