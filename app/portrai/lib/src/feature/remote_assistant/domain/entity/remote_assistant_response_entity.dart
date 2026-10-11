import 'package:equatable/equatable.dart';
import 'package:portrai/src/feature/project/project.dart';

final class RemoteAssistantResponseEntity extends Equatable {
  RemoteAssistantResponseEntity({
    required this.text,
    required List<ProjectEntity> projects,
  }) : projects = List.unmodifiable(projects);

  final String text;
  final List<ProjectEntity> projects;

  @override
  List<Object?> get props => [text, projects];

  // Generated text must stay out of use case success logs, even in debug mode.
  @override
  bool get stringify => false;
}
