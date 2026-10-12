import 'package:equatable/equatable.dart';

class ProjectMetricEntity extends Equatable {
  const ProjectMetricEntity({required this.label, required this.value});

  final String label;
  final String value;

  @override
  List<Object?> get props => [label, value];
}
