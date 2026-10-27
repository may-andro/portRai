import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingEvent {
  const LoadSettingsEvent();
}

/// A settings entry that opens another screen.
enum SettingEntry { language, theme, role, jobOpenings, developerMenu }

class SettingEntryClickEvent extends SettingEvent {
  const SettingEntryClickEvent(this.entry);

  final SettingEntry entry;

  @override
  List<Object?> get props => [entry];
}

// Tracking Events
final class ScreenVisibleEvent extends SettingEvent {
  const ScreenVisibleEvent();
}
