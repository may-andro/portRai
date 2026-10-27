import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/domain/_domain.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_event.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_state.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/tracking/_tracking.dart';

@register
class FooterBloc extends Bloc<FooterEvent, FooterState> {
  FooterBloc(
    this._getProfileUseCase,
    this._openExternalUrlUseCase,
    this._openEmailUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadDataEvent>(_mapLoadDataEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<ResumeClickEvent>(_mapResumeClickEventToState);
    on<OpenEmailClientEvent>(_mapOpenEmailClientEventToState);
  }

  final GetProfileUseCase _getProfileUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final OpenEmailUseCase _openEmailUseCase;
  final FooterTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadDataEventToState(
    LoadDataEvent event,
    Emitter<FooterState> emit,
  ) async {
    if (event.profile case final profile?) {
      emit(LoadedState(profile: profile));
      return;
    }
    final profileEither = await _getProfileUseCase();
    if (profileEither.isLeft) {
      emit(const UnavailableState());
      return;
    }
    emit(LoadedState(profile: profileEither.right));
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<FooterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(Uri.parse(event.url)),
    );
    eitherResult.fold((failure) {}, (success) {
      _trackingDelegate.trackExternalLinkClick(event.label);
    });
  }

  FutureOr<void> _mapOpenEmailClientEventToState(
    OpenEmailClientEvent event,
    Emitter<FooterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openEmailUseCase(currentState.profile.email);
    eitherResult.fold((failure) {}, (success) {
      _trackingDelegate.trackEmailClick(event.email);
    });
  }

  void _mapResumeClickEventToState(
    ResumeClickEvent event,
    Emitter<FooterState> emit,
  ) => _trackingDelegate.trackResumeClick(event.label);
}
