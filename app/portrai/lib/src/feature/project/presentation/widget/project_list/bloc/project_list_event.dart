import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class ProjectListEvent extends Equatable {
  const ProjectListEvent();

  @override
  List<Object?> get props => [];
}

final class ProjectClickEvent extends ProjectListEvent {
  const ProjectClickEvent(this.projectId);

  final String projectId;

  @override
  List<Object?> get props => [projectId];
}
