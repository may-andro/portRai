import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_event.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/bloc/profile_state.dart';
import 'package:portrai/src/feature/profile/presentation/screen/profile/tracking/_tracking.dart';

const _logTag = 'ProfileBloc';

@register
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(
    this._getProfileUseCase,
    this._openExternalUrlUseCase,
    this._logReporter,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadProfileEvent>(_mapLoadExperienceEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
  }

  final GetProfileUseCase _getProfileUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final LogReporter _logReporter;
  final ProfileTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadExperienceEventToState(
    LoadProfileEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const LoadingState());

    final eitherProfileResult = await _getProfileUseCase();
    eitherProfileResult.fold(
      (failure) => emit(ErrorState(failure: failure)),
      (profile) => emit(LoadedState(profile: profile)),
    );
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(Uri.parse(event.url)),
    );
    eitherResult.fold(
      (failure) {
        _logReporter.error(
          'Failed to open external URL: ${event.url}',
          error: failure.cause,
          tag: _logTag,
        );
      },
      (success) {
        _trackingDelegate.trackExternalLinkClick(event.label);
      },
    );
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
