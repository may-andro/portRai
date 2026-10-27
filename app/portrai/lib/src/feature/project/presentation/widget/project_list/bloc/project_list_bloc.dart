import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/project_list_event.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/project_list_state.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/tracking/_tracking.dart';

@register
class ProjectListBloc extends Bloc<ProjectListEvent, ProjectListState> {
  ProjectListBloc(this._trackingDelegate) : super(const ProjectListState()) {
    on<ProjectClickEvent>(_mapProjectClickEventToState);
  }

  final ProjectListTrackingDelegate _trackingDelegate;

  void _mapProjectClickEventToState(
    ProjectClickEvent event,
    Emitter<ProjectListState> emit,
  ) => _trackingDelegate.trackProjectClick(
    label: event.label,
    projectId: event.projectId,
  );
}
