import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/feature_flag/domain/_domain.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/feature_flag_event.dart';
import 'package:portrai/src/feature/feature_flag/presentation/bloc/feature_flag_state.dart';
import 'package:portrai/src/feature/feature_flag/presentation/tracking/_tracking.dart';

@register
class FeatureFlagBloc extends Bloc<FeatureFlagEvent, FeatureFlagState> {
  FeatureFlagBloc(
    this._getAllFeatureFlagsUseCase,
    this._updateFeatureFlagUseCase,
    this._resetFeatureFlagsUseCase,
    this._trackingDelegate,
  ) : super(const FeatureFlagInitialState()) {
    on<LoadFeatureFlagEvent>(_onLoadFeatureFlag);
    on<ToggleFeatureFlagEvent>(_onToggleFeatureFlag);
    on<ResetAllFeatureFlagsEvent>(_onResetAllFeatureFlags);
    on<SearchFeatureFlagsEvent>(_onSearchFeatureFlags);
    on<ToggleViewModeEvent>(_onToggleViewMode);
    on<ScreenVisibleEvent>(_onScreenVisible);
    on<ViewStateVisibleEvent>(_onViewStateVisible);
  }

  final GetAllFeatureFlagsUseCase _getAllFeatureFlagsUseCase;
  final UpdateFeatureFlagUseCase _updateFeatureFlagUseCase;
  final ResetFeatureFlagsUseCase _resetFeatureFlagsUseCase;
  final FeatureFlagTrackingDelegate _trackingDelegate;

  Future<void> _onLoadFeatureFlag(
    LoadFeatureFlagEvent event,
    Emitter<FeatureFlagState> emit,
  ) async {
    // Preserve existing state properties if available
    final previousState = state is FeatureFlagLoadedState
        ? state as FeatureFlagLoadedState
        : null;

    emit(const FeatureFlagLoadingState());

    final result = await _getAllFeatureFlagsUseCase();
    result.fold(
      (failure) => emit(FeatureFlagErrorState(failure.toString())),
      (flags) => emit(
        previousState != null
            ? previousState.copyWith(allFlags: flags)
            : FeatureFlagLoadedState(flags),
      ),
    );
  }

  Future<void> _onToggleFeatureFlag(
    ToggleFeatureFlagEvent event,
    Emitter<FeatureFlagState> emit,
  ) async {
    if (state is! FeatureFlagLoadedState) return;

    final currentState = state as FeatureFlagLoadedState;
    final updatedFlag = event.flag.copyWith(
      isEnabled: !event.flag.isEnabled,
      isOverridden: true,
    );

    final updatedFlags = currentState.allFlags.map((flag) {
      return flag.flag == updatedFlag.flag ? updatedFlag : flag;
    }).toList();

    emit(
      currentState.copyWith(allFlags: updatedFlags, hasManipulatedFlags: true),
    );

    await _updateFeatureFlagUseCase(updatedFlag);
  }

  Future<void> _onResetAllFeatureFlags(
    ResetAllFeatureFlagsEvent event,
    Emitter<FeatureFlagState> emit,
  ) async {
    // Preserve viewMode and searchQuery during reset
    final previousState = state is FeatureFlagLoadedState
        ? state as FeatureFlagLoadedState
        : null;

    emit(const FeatureFlagLoadingState());

    await _resetFeatureFlagsUseCase();

    // Load flags with preserved state, but reset hasManipulatedFlags
    final result = await _getAllFeatureFlagsUseCase();
    result.fold(
      (failure) => emit(FeatureFlagErrorState(failure.toString())),
      (flags) => emit(
        previousState != null
            ? FeatureFlagLoadedState(
                flags,
                viewMode: previousState.viewMode,
                searchQuery: previousState.searchQuery,
              )
            : FeatureFlagLoadedState(flags),
      ),
    );
  }

  void _onSearchFeatureFlags(
    SearchFeatureFlagsEvent event,
    Emitter<FeatureFlagState> emit,
  ) {
    if (state is! FeatureFlagLoadedState) return;

    final currentState = state as FeatureFlagLoadedState;
    emit(currentState.copyWith(searchQuery: event.query));
  }

  void _onToggleViewMode(
    ToggleViewModeEvent event,
    Emitter<FeatureFlagState> emit,
  ) {
    if (state is! FeatureFlagLoadedState) return;

    final currentState = state as FeatureFlagLoadedState;
    final newMode = currentState.viewMode == FeatureFlagViewMode.list
        ? FeatureFlagViewMode.grid
        : FeatureFlagViewMode.list;
    emit(currentState.copyWith(viewMode: newMode));
  }

  FutureOr<void> _onScreenVisible(
    ScreenVisibleEvent event,
    Emitter<FeatureFlagState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  FutureOr<void> _onViewStateVisible(
    ViewStateVisibleEvent event,
    Emitter<FeatureFlagState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
