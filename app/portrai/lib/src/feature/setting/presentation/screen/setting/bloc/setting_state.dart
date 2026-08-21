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
  });

  final bool isLanguageSelectorEnabled;

  @override
  List<Object?> get props => [isLanguageSelectorEnabled];
}

class SettingErrorState extends SettingState {
  const SettingErrorState(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
