import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class DesignSystemCardEvent extends Equatable {
  const DesignSystemCardEvent();

  @override
  List<Object?> get props => [];
}

final class DesignSystemCardClickEvent extends DesignSystemCardEvent {
  const DesignSystemCardClickEvent(this.label);

  /// The tapped element, such as a button or card.
  final String label;

  @override
  List<Object?> get props => [label];
}
