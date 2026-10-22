import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
abstract class LocaleSelectionEvent extends Equatable {
  const LocaleSelectionEvent();

  @override
  List<Object?> get props => [];
}

// Data Events
class LoadLocaleEvent extends LocaleSelectionEvent {
  const LoadLocaleEvent();
}

class UpdateLocaleEvent extends LocaleSelectionEvent {
  const UpdateLocaleEvent(this.updatedLocale);

  final Locale updatedLocale;

  @override
  List<Object?> get props => [updatedLocale];
}

// Tracking Events
final class ScreenVisibleEvent extends LocaleSelectionEvent {
  const ScreenVisibleEvent(this.isDialog);

  final bool isDialog;

  @override
  List<Object?> get props => [...super.props, isDialog];
}

final class ViewStateVisibleEvent extends LocaleSelectionEvent {
  const ViewStateVisibleEvent(this.trackingId);

  final String trackingId;

  @override
  List<Object?> get props => [trackingId];
}
