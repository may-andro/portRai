import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';
import 'package:use_case/use_case.dart';

enum RemoteAssistantStatus { loading, unavailable, ready }

class RemoteAssistantSurface extends Equatable {
  const RemoteAssistantSurface({
    required this.messageIndex,
    required this.genuiController,
    required this.surfaceId,
  });

  final int messageIndex;
  final AssistantGenuiController genuiController;
  final String surfaceId;

  @override
  List<Object?> get props => [messageIndex, genuiController, surfaceId];
}

class RemoteAssistantState extends Equatable {
  const RemoteAssistantState({
    this.status = RemoteAssistantStatus.loading,
    this.isFeatureEnabled = false,
    this.isGenerativeUiEnabled = false,
    this.isLoadingContext = false,
    this.isSendingQuestion = false,
    this.portfolioContext,
    this.messages = const [],
    this.genuiSurfaces = const [],
    this.partialAnswer = '',
    this.failure,
  });

  final RemoteAssistantStatus status;
  final bool isFeatureEnabled;
  final bool isGenerativeUiEnabled;
  final bool isLoadingContext;
  final bool isSendingQuestion;
  final String? portfolioContext;
  final List<AssistantMessageEntity> messages;
  final List<RemoteAssistantSurface> genuiSurfaces;
  final String partialAnswer;
  final Failure? failure;

  bool get isReady => status == RemoteAssistantStatus.ready;

  bool get _hasPendingSurface =>
      genuiSurfaces.any((surface) => surface.messageIndex == messages.length);

  List<AssistantMessageEntity> get visibleMessages => [
    ...messages,
    if (partialAnswer.isNotEmpty || _hasPendingSurface)
      AssistantMessageEntity(
        content: AssistantTextResponseEntity(text: partialAnswer),
        isUser: false,
      ),
  ];

  RemoteAssistantState copyWith({
    RemoteAssistantStatus? status,
    bool? isFeatureEnabled,
    bool? isGenerativeUiEnabled,
    bool? isLoadingContext,
    bool? isSendingQuestion,
    String? portfolioContext,
    bool clearContext = false,
    List<AssistantMessageEntity>? messages,
    List<RemoteAssistantSurface>? genuiSurfaces,
    bool clearGenuiSurfaces = false,
    String? partialAnswer,
    Failure? failure,
    bool clearFailure = false,
  }) => RemoteAssistantState(
    status: status ?? this.status,
    isFeatureEnabled: isFeatureEnabled ?? this.isFeatureEnabled,
    isGenerativeUiEnabled: isGenerativeUiEnabled ?? this.isGenerativeUiEnabled,
    isLoadingContext: isLoadingContext ?? this.isLoadingContext,
    isSendingQuestion: isSendingQuestion ?? this.isSendingQuestion,
    portfolioContext: clearContext
        ? null
        : portfolioContext ?? this.portfolioContext,
    messages: messages ?? this.messages,
    genuiSurfaces: clearGenuiSurfaces
        ? const []
        : genuiSurfaces ?? this.genuiSurfaces,
    partialAnswer: partialAnswer ?? this.partialAnswer,
    failure: clearFailure ? null : failure ?? this.failure,
  );

  @override
  List<Object?> get props => [
    status,
    isFeatureEnabled,
    isGenerativeUiEnabled,
    isLoadingContext,
    isSendingQuestion,
    portfolioContext,
    messages,
    genuiSurfaces,
    partialAnswer,
    failure,
  ];

  @override
  String toString() =>
      'RemoteAssistantState(status: $status, sending: $isSendingQuestion, '
      'messages: ${messages.length}, failure: ${failure?.runtimeType})';
}
