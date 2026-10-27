import 'package:equatable/equatable.dart';

/// The list shows the projects it is given, so its bloc only handles taps
/// and keeps no state of its own.
final class ProjectListState extends Equatable {
  const ProjectListState();

  @override
  List<Object?> get props => [];
}
