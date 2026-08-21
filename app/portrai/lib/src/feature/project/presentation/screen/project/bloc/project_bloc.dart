import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/project_event.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/project_state.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/extension/_extension.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/tracking/_tracking.dart';

@register
class ProjectBloc extends Bloc<ProjectEvent, ProjectState> {
  ProjectBloc(this._openExternalUrlUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<LoadProjectEvent>(_mapLoadProjectEventToState);
    on<LoadingContentViewVisibleEvent>(
      _mapLoadingContentViewVisibleEventToState,
    );
    on<SuccessContentViewVisibleEvent>(
      _mapSuccessContentViewVisibleEventToState,
    );
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<SectionVisibleEvent>(_mapSectionVisibleEventToState);
    on<HeaderTabClickEvent>(_mapHeaderTabClickEventToState);
  }

  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final ProjectTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ProjectState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapLoadProjectEventToState(
    LoadProjectEvent event,
    Emitter<ProjectState> emit,
  ) {
    emit(LoadedState(project: event.project, sections: event.project.sections));
  }

  FutureOr<void> _mapLoadingContentViewVisibleEventToState(
    LoadingContentViewVisibleEvent event,
    Emitter<ProjectState> emit,
  ) {
    _trackingDelegate.trackLoadingContentView();
  }

  FutureOr<void> _mapSuccessContentViewVisibleEventToState(
    SuccessContentViewVisibleEvent event,
    Emitter<ProjectState> emit,
  ) {
    _trackingDelegate.trackLoadedContentView();
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<ProjectState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(Uri.parse(event.url)),
    );
    eitherResult.fold(
      (failure) {
        // Handle failure if needed
      },
      (success) {
        // Handle success if needed
      },
    );
    _trackingDelegate.trackAvailabilityLinkClick(event.label);
  }

  FutureOr<void> _mapHeaderTabClickEventToState(
    HeaderTabClickEvent event,
    Emitter<ProjectState> emit,
  ) {
    _trackingDelegate.trackTabItemSelection(event.section.trackingId);
  }

  FutureOr<void> _mapSectionVisibleEventToState(
    SectionVisibleEvent event,
    Emitter<ProjectState> emit,
  ) {
    _trackingDelegate.trackSectionView(event.trackingId);
  }
}
