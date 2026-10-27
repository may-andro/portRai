import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ProjectListEvent extends Equatable {
  const ProjectListEvent();

  @override
  List<Object?> get props => [];
}

final class ProjectClickEvent extends ProjectListEvent {
  const ProjectClickEvent({required this.label, required this.projectId});

  /// The tapped element, such as a button or card.
  final String label;

  /// ID of the project that opens.
  final String projectId;

  @override
  List<Object?> get props => [label, projectId];
}
