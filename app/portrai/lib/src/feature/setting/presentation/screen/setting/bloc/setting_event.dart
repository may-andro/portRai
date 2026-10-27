import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingEvent {
  const LoadSettingsEvent();
}

/// A settings entry was tapped; [entryName] labels the click.
class SettingEntryClickEvent extends SettingEvent {
  const SettingEntryClickEvent(this.entryName);

  final String entryName;

  @override
  List<Object?> get props => [entryName];
}

// Tracking Events
final class ScreenVisibleEvent extends SettingEvent {
  const ScreenVisibleEvent();
}
