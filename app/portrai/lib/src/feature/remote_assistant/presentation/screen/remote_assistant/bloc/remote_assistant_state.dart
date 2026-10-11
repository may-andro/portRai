import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:use_case/use_case.dart';

enum RemoteAssistantStatus { loading, unavailable, off, ready }

class RemoteAssistantState extends Equatable {
  const RemoteAssistantState({
    this.status = RemoteAssistantStatus.loading,
    this.isUpdatingPreference = false,
    this.isLoadingContext = false,
    this.isSendingQuestion = false,
    this.portfolioContext,
    this.messages = const [],
    this.partialAnswer = '',
    this.failure,
  });

  final RemoteAssistantStatus status;
  final bool isUpdatingPreference;
  final bool isLoadingContext;
  final bool isSendingQuestion;
  final String? portfolioContext;
  final List<AssistantMessageEntity> messages;
  final String partialAnswer;
  final Failure? failure;

  bool get isReady => status == RemoteAssistantStatus.ready;

  List<AssistantMessageEntity> get visibleMessages => [
    ...messages,
    if (partialAnswer.isNotEmpty)
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: partialAnswer),
        isUser: false,
      ),
  ];

  RemoteAssistantState copyWith({
    RemoteAssistantStatus? status,
    bool? isUpdatingPreference,
    bool? isLoadingContext,
    bool? isSendingQuestion,
    String? portfolioContext,
    bool clearContext = false,
    List<AssistantMessageEntity>? messages,
    String? partialAnswer,
    Failure? failure,
    bool clearFailure = false,
  }) => RemoteAssistantState(
    status: status ?? this.status,
    isUpdatingPreference: isUpdatingPreference ?? this.isUpdatingPreference,
    isLoadingContext: isLoadingContext ?? this.isLoadingContext,
    isSendingQuestion: isSendingQuestion ?? this.isSendingQuestion,
    portfolioContext: clearContext
        ? null
        : portfolioContext ?? this.portfolioContext,
    messages: messages ?? this.messages,
    partialAnswer: partialAnswer ?? this.partialAnswer,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    isUpdatingPreference,
    isLoadingContext,
    isSendingQuestion,
    portfolioContext,
    messages,
    partialAnswer,
    failure,
  ];

  @override
  String toString() =>
      'RemoteAssistantState(status: $status, sending: $isSendingQuestion, '
      'messages: ${messages.length}, failure: ${failure?.runtimeType})';
}
