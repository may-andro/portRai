import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_event.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/footer_state.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/tracking/_tracking.dart';

const _logTag = 'FooterBloc';

@register
class FooterBloc extends Bloc<FooterEvent, FooterState> {
  FooterBloc(
    this._openExternalUrlUseCase,
    this._openEmailUseCase,
    this._logReporter,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadDataEvent>(_mapLoadDataEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
    on<OpenEmailClientEvent>(_mapOpenEmailClientEventToState);
  }

  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final OpenEmailUseCase _openEmailUseCase;
  final LogReporter _logReporter;
  final FooterTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadDataEventToState(
    LoadDataEvent event,
    Emitter<FooterState> emit,
  ) {
    emit(LoadedState(profile: event.profile));
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

  FutureOr<void> _mapOpenEmailClientEventToState(
    OpenEmailClientEvent event,
    Emitter<FooterState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openEmailUseCase(currentState.profile.email);
    eitherResult.fold(
      (failure) {
        _logReporter.error(
          'Failed to open email client: ${event.email}',
          error: failure.cause,
          tag: _logTag,
        );
      },
      (success) {
        _trackingDelegate.trackEmailClick(event.email);
      },
    );
  }
}
