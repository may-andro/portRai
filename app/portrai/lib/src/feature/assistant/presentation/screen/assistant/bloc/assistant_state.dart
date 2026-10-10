import 'package:equatable/equatable.dart';

class AssistantMessage extends Equatable {
  const AssistantMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  List<Object?> get props => [text, isUser];
}

class AssistantState extends Equatable {
  const AssistantState({
    this.portfolioContext,
    this.isFeatureEnabled = true,
    this.isLoadingContext = true,
    this.isEnabled = false,
    this.isPreparingModel = false,
    this.isModelReady = false,
    this.isModelDownloaded = false,
    this.downloadProgress = 0,
    this.isSendingQuestion = false,
    this.messages = const [],
    this.hasError = false,
  });

  final String? portfolioContext;
  final bool isFeatureEnabled;
  final bool isLoadingContext;
  final bool isEnabled;
  final bool isPreparingModel;
  final bool isModelReady;
  final bool isModelDownloaded;
  final int downloadProgress;
  final bool isSendingQuestion;
  final List<AssistantMessage> messages;
  final bool hasError;

  AssistantState copyWith({
    String? portfolioContext,
    bool? isFeatureEnabled,
    bool? isLoadingContext,
    bool? isEnabled,
    bool? isPreparingModel,
    bool? isModelReady,
    bool? isModelDownloaded,
    int? downloadProgress,
    bool? isSendingQuestion,
    List<AssistantMessage>? messages,
    bool? hasError,
  }) {
    return AssistantState(
      portfolioContext: portfolioContext ?? this.portfolioContext,
      isFeatureEnabled: isFeatureEnabled ?? this.isFeatureEnabled,
      isLoadingContext: isLoadingContext ?? this.isLoadingContext,
      isEnabled: isEnabled ?? this.isEnabled,
      isPreparingModel: isPreparingModel ?? this.isPreparingModel,
      isModelReady: isModelReady ?? this.isModelReady,
      isModelDownloaded: isModelDownloaded ?? this.isModelDownloaded,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isSendingQuestion: isSendingQuestion ?? this.isSendingQuestion,
      messages: messages ?? this.messages,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [
    portfolioContext,
    isFeatureEnabled,
    isLoadingContext,
    isEnabled,
    isPreparingModel,
    isModelReady,
    isModelDownloaded,
    downloadProgress,
    isSendingQuestion,
    messages,
    hasError,
  ];
}
