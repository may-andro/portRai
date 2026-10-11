import 'package:equatable/equatable.dart';

sealed class LocalAssistantEvent extends Equatable {
  const LocalAssistantEvent();

  @override
  List<Object?> get props => [];
}

class LocalAssistantStartedEvent extends LocalAssistantEvent {
  const LocalAssistantStartedEvent();
}

class LocalAssistantInitializedEvent extends LocalAssistantEvent {
  const LocalAssistantInitializedEvent();
}

class EnableLocalAssistantClickEvent extends LocalAssistantEvent {
  const EnableLocalAssistantClickEvent();
}

class DisableLocalAssistantClickEvent extends LocalAssistantEvent {
  const DisableLocalAssistantClickEvent({required this.deleteModel});

  final bool deleteModel;

  @override
  List<Object?> get props => [deleteModel];
}

class SendLocalAssistantQuestionClickEvent extends LocalAssistantEvent {
  const SendLocalAssistantQuestionClickEvent(this.question);

  final String question;

  @override
  List<Object?> get props => [question];
}
