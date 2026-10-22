import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/user/user.dart';
import 'package:use_case/use_case.dart';

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
    this.isJobOpeningsEnabled = false,
    this.isNotificationSettingAvailable = false,
    this.userRole,
  });

  final bool isLanguageSelectorEnabled;
  final bool isDevMenuEnabled;
  final bool isLocalAssistantAvailable;
  final bool isJobOpeningsEnabled;

  /// The platform has a notification permission for the app to show.
  final bool isNotificationSettingAvailable;
  final UserRole? userRole;

  @override
  List<Object?> get props => [
    isLanguageSelectorEnabled,
    isDevMenuEnabled,
    isLocalAssistantAvailable,
    isJobOpeningsEnabled,
    isNotificationSettingAvailable,
    userRole,
  ];
}

class SettingErrorState extends SettingState {
  const SettingErrorState(this.failure);

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
