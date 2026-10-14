import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ExpertiseEvent extends Equatable {
  const ExpertiseEvent();

  @override
  List<Object?> get props => [];
}

final class LoadExpertiseEvent extends ExpertiseEvent {
  const LoadExpertiseEvent();
}

// Tracking Events
final class ScreenVisibleEvent extends ExpertiseEvent {
  const ScreenVisibleEvent();
}

final class ContentVisibleEvent extends ExpertiseEvent {
  const ContentVisibleEvent();
}
