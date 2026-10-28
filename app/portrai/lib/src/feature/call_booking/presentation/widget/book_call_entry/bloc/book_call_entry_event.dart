import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class BookCallEntryEvent extends Equatable {
  const BookCallEntryEvent();

  @override
  List<Object?> get props => [];
}

final class LoadBookCallEntryEvent extends BookCallEntryEvent {
  const LoadBookCallEntryEvent();
}

final class BookCallClickEvent extends BookCallEntryEvent {
  const BookCallClickEvent({required this.label, this.topic});

  /// The tapped element, such as a button.
  final String label;

  /// What the call is about, such as a service's title, or null.
  final String? topic;

  @override
  List<Object?> get props => [label, topic];
}
