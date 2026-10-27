import 'package:equatable/equatable.dart';

abstract class SettingEvent extends Equatable {
  const SettingEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettingsEvent extends SettingEvent {
  const LoadSettingsEvent();
}

final class SettingEntryClickEvent extends SettingEvent {
  const SettingEntryClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object?> get props => [label];
}

// Tracking Events
final class ScreenVisibleEvent extends SettingEvent {
  const ScreenVisibleEvent();
}
