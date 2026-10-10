import 'package:equatable/equatable.dart';

class AssistantMessage extends Equatable {
  const AssistantMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;

  @override
  List<Object?> get props => [text, isUser];
}

/// Where the on-device model is in its lifecycle. Exactly one applies, so
/// states such as "ready while still downloading" cannot be represented.
sealed class AssistantStatus extends Equatable {
  const AssistantStatus();

  @override
  List<Object?> get props => [];
}

/// The feature flag is off.
class AssistantUnavailable extends AssistantStatus {
  const AssistantUnavailable();
}

/// Available, but the user has not enabled it.
class AssistantOff extends AssistantStatus {
  const AssistantOff();
}

/// Enabled and downloading or loading the model; [progress] is 0 to 100.
class AssistantDownloading extends AssistantStatus {
  const AssistantDownloading([this.progress = 0]);

  final int progress;

  @override
  List<Object?> get props => [progress];
}

class AssistantReady extends AssistantStatus {
  const AssistantReady();
}

/// Enabled, but the model could not be downloaded or loaded.
class AssistantFailed extends AssistantStatus {
  const AssistantFailed();
}

class AssistantState extends Equatable {
  const AssistantState({
    this.status = const AssistantOff(),
    this.portfolioContext,
    this.isLoadingContext = true,
    this.isModelDownloaded = false,
    this.isSendingQuestion = false,
    this.messages = const [],
    this.hasError = false,
  });

  final AssistantStatus status;
  final String? portfolioContext;
  final bool isLoadingContext;

  /// The model file is on disk, which stays true while the assistant is off
  /// and the user chose to keep it.
  final bool isModelDownloaded;
  final bool isSendingQuestion;
  final List<AssistantMessage> messages;

  /// The context failed to load, or the last answer failed.
  final bool hasError;

  bool get isAvailable => status is! AssistantUnavailable;
  bool get isReady => status is AssistantReady;
  bool get isDownloading => status is AssistantDownloading;
  bool get hasFailed => status is AssistantFailed;
  bool get isEnabled => isDownloading || isReady || hasFailed;

  AssistantState copyWith({
    AssistantStatus? status,
    String? portfolioContext,
    bool? isLoadingContext,
    bool? isModelDownloaded,
    bool? isSendingQuestion,
    List<AssistantMessage>? messages,
    bool? hasError,
  }) {
    return AssistantState(
      status: status ?? this.status,
      portfolioContext: portfolioContext ?? this.portfolioContext,
      isLoadingContext: isLoadingContext ?? this.isLoadingContext,
      isModelDownloaded: isModelDownloaded ?? this.isModelDownloaded,
      isSendingQuestion: isSendingQuestion ?? this.isSendingQuestion,
      messages: messages ?? this.messages,
      hasError: hasError ?? this.hasError,
    );
  }

  @override
  List<Object?> get props => [
    status,
    portfolioContext,
    isLoadingContext,
    isModelDownloaded,
    isSendingQuestion,
    messages,
    hasError,
  ];
}
