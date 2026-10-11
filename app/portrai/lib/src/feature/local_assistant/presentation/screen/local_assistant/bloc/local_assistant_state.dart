import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/assistant/assistant.dart';

/// Where the on-device model is in its lifecycle. Exactly one applies, so
/// states such as "ready while still downloading" cannot be represented.
sealed class LocalAssistantStatus extends Equatable {
  const LocalAssistantStatus();

  @override
  List<Object?> get props => [];
}

/// The feature flag is off.
class LocalAssistantUnavailable extends LocalAssistantStatus {
  const LocalAssistantUnavailable();
}

/// Available, but the user has not enabled it.
class LocalAssistantOff extends LocalAssistantStatus {
  const LocalAssistantOff();
}

/// Enabled and downloading or loading the model; [progress] is 0 to 100.
class LocalAssistantDownloading extends LocalAssistantStatus {
  const LocalAssistantDownloading([this.progress = 0]);

  final int progress;

  @override
  List<Object?> get props => [progress];
}

class LocalAssistantReady extends LocalAssistantStatus {
  const LocalAssistantReady();
}

/// Enabled, but the model could not be downloaded or loaded.
class LocalAssistantFailed extends LocalAssistantStatus {
  const LocalAssistantFailed();
}

class LocalAssistantState extends Equatable {
  const LocalAssistantState({
    this.status = const LocalAssistantOff(),
    this.portfolioContext,
    this.isLoadingContext = true,
    this.isModelDownloaded = false,
    this.isSendingQuestion = false,
    this.messages = const [],
    this.hasError = false,
  });

  final LocalAssistantStatus status;
  final String? portfolioContext;
  final bool isLoadingContext;

  /// The model file is on disk, which stays true while the assistant is off
  /// and the user chose to keep it.
  final bool isModelDownloaded;
  final bool isSendingQuestion;
  final List<AssistantMessageEntity> messages;

  /// The context failed to load, or the last answer failed.
  final bool hasError;

  bool get isAvailable => status is! LocalAssistantUnavailable;
  bool get isReady => status is LocalAssistantReady;
  bool get isDownloading => status is LocalAssistantDownloading;
  bool get hasFailed => status is LocalAssistantFailed;
  bool get isEnabled => isDownloading || isReady || hasFailed;

  LocalAssistantState copyWith({
    LocalAssistantStatus? status,
    String? portfolioContext,
    bool? isLoadingContext,
    bool? isModelDownloaded,
    bool? isSendingQuestion,
    List<AssistantMessageEntity>? messages,
    bool? hasError,
  }) {
    return LocalAssistantState(
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
