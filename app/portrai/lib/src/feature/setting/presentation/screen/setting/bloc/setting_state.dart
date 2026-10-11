import 'package:equatable/equatable.dart';

sealed class SettingState extends Equatable {
  const SettingState();

  @override
  List<Object?> get props => [];
}

class SettingInitialState extends SettingState {
  const SettingInitialState();
}

class SettingLoadingState extends SettingState {
  const SettingLoadingState();
}

class SettingLoadedState extends SettingState {
  const SettingLoadedState({
    required this.isLanguageSelectorEnabled,
    this.isDevMenuEnabled = false,
    this.isLocalAssistantAvailable = false,
    this.isRemoteAssistantAvailable = false,
  });

  final bool isLanguageSelectorEnabled;
  final bool isDevMenuEnabled;
  final bool isLocalAssistantAvailable;
  final bool isRemoteAssistantAvailable;

  @override
  List<Object?> get props => [
    isLanguageSelectorEnabled,
    isDevMenuEnabled,
    isLocalAssistantAvailable,
    isRemoteAssistantAvailable,
  ];
}

class SettingErrorState extends SettingState {
  const SettingErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
