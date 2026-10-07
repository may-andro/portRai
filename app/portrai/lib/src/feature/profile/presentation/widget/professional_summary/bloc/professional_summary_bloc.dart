import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/external_app_handler.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_event.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/professional_summary_state.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/tracking/_tracking.dart';

@register
class ProfessionalSummaryBloc
    extends Bloc<ProfessionalSummaryEvent, ProfessionalSummaryState> {
  ProfessionalSummaryBloc(
    this._openEmailUseCase,
    this._openExternalUrlUseCase,
    this._trackingDelegate,
  ) : super(const LoadingState()) {
    on<LoadDataEvent>(_mapLoadDataEventToState);
    on<OpenEmailClientEvent>(_mapOpenEmailClientEventToState);
    on<OpenExternalUrlEvent>(_mapOpenExternalUrlEventToState);
  }

  final OpenEmailUseCase _openEmailUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final ProfessionalSummaryTrackingDelegate _trackingDelegate;

  FutureOr<void> _mapLoadDataEventToState(
    LoadDataEvent event,
    Emitter<ProfessionalSummaryState> emit,
  ) {
    emit(LoadedState(profile: event.profile));
  }

  FutureOr<void> _mapOpenEmailClientEventToState(
    OpenEmailClientEvent event,
    Emitter<ProfessionalSummaryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! LoadedState) return null;

    final eitherResult = await _openEmailUseCase(currentState.profile.email);
    eitherResult.fold((failure) {}, (success) {
      _trackingDelegate.trackEmailClick(event.email);
    });
  }

  FutureOr<void> _mapOpenExternalUrlEventToState(
    OpenExternalUrlEvent event,
    Emitter<ProfessionalSummaryState> emit,
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
}
