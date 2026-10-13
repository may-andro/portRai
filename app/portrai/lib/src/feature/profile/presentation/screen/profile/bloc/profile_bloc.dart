import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_event.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_state.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/tracking/_tracking.dart';
import 'package:portrai/src/feature/project/project.dart';

@register
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._getProfileUseCase,
    this._getProjectsUseCase,
    this._openExternalUrlUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadProfileEvent>(_mapLoadProfileEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetProfileUseCase _getProfileUseCase;
  final GetProjectsUseCase _getProjectsUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final ProfileTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadProfileEventToState(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const LoadingState());

    final eitherProfileResult = await _getProfileUseCase();
    final eitherProjectsResult = await _getProjectsUseCase();
    // Places are decorative, so a failed projects load must not fail the page.
    final workPlaces = eitherProjectsResult.fold(
      (_) => const <WorkPlaceEntity>[],
      _toWorkPlaces,
    );
    eitherProfileResult.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (profile) => emit(LoadedState(profile: profile, workPlaces: workPlaces)),
    );
  }

  /// One place per distinct market location across all projects.
  List<WorkPlaceEntity> _toWorkPlaces(List<ProjectEntity> projects) {
    final places = <String, WorkPlaceEntity>{};
    for (final market in projects.expand((project) => project.markets)) {
      final key =
          '${market.latitude.toStringAsFixed(1)},'
          '${market.longitude.toStringAsFixed(1)}';
      places.putIfAbsent(
        key,
        () => WorkPlaceEntity(
          country: market.country,
          latitude: market.latitude,
          longitude: market.longitude,
        ),
      );
    }
    return places.values.toList();
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return;

    final eitherResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(Uri.parse(event.url)),
    );
    if (eitherResult.isRight) {
      _trackingDelegate.trackExternalLinkClick(event.label);
    }
  }

  // Tracking Events
  FutureOr<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<ProfileState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<ProfileState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
