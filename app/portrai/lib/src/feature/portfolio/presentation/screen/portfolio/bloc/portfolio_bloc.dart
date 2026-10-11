import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/local_assistant/local_assistant.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_event.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_state.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/tracking/_tracking.dart';
import 'package:portrai/src/feature/remote_assistant/remote_assistant.dart';
import 'package:use_case/use_case.dart';

@register
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc(
    this._getPortfolioUseCase,
    this._trackingDelegate,
    this._getLocalAvailability,
    this._getRemoteAvailability,
  ) : super(const LoadingState()) {
    on<LoadPortfolioEvent>(_mapLoadPortfolioEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<DrawerClickEvent>(_mapDrawerClickEventToState);
    on<SectionNavigationEvent>(_mapSectionNavigationEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
    on<SectionVisibleEvent>(_mapSectionVisibleEventToState);
    on<AssistantLaunchClickEvent>(_mapAssistantLaunchClickEventToState);
  }

  final GetPortfolioUseCase _getPortfolioUseCase;
  final PortfolioTrackingDelegate _trackingDelegate;
  final GetLocalAssistantAvailabilityUseCase _getLocalAvailability;
  final GetRemoteAssistantAvailabilityUseCase _getRemoteAvailability;
  int _availabilityRevision = 0;

  Future<void> _mapLoadPortfolioEventToState(
    LoadPortfolioEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const LoadingState());
    try {
      final result = await _getPortfolioUseCase();
      if (result.isRight) {
        emit(LoadedState(portfolio: result.right));
        await _refreshAssistantAvailability(emit);
        return;
      }
      emit(ErrorState(result.left));
    } catch (e) {
      emit(const ErrorState(UnknownFailure()));
    }
  }

  FutureOr<void> _mapSectionNavigationEventToState(
    SectionNavigationEvent event,
    Emitter<PortfolioState> emit,
  ) {
    switch (event.source) {
      case NavigationSource.drawer:
        _trackingDelegate.trackDrawerItemSelection(event.sectionId);
      case NavigationSource.header:
        _trackingDelegate.trackTabItemSelection(event.sectionId);
      case NavigationSource.scroll:
        break;
    }

    if (state is LoadedState) {
      final loadedState = state as LoadedState;
      emit(
        loadedState.copyWith(
          selectedSectionIndex: event.sectionIndex,
          lastNavigationSource: event.source,
        ),
      );
    }
  }

  // Tracking Event Handlers
  Future<void> _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    _trackingDelegate.trackScreenView();
    await _refreshAssistantAvailability(emit);
  }

  void _mapAssistantLaunchClickEventToState(
    AssistantLaunchClickEvent event,
    Emitter<PortfolioState> emit,
  ) => _trackingDelegate.trackAssistantLaunch(isLocal: event.isLocal);

  Future<void> _refreshAssistantAvailability(
    Emitter<PortfolioState> emit,
  ) async {
    final revision = ++_availabilityRevision;
    final remote = await _getRemoteAvailability();
    final local = await _getLocalAvailability();
    if (emit.isDone ||
        revision != _availabilityRevision ||
        state is! LoadedState) {
      return;
    }
    emit(
      (state as LoadedState).copyWith(
        isRemoteAssistantAvailable: remote.isRight && remote.right.isAvailable,
        isLocalAssistantAvailable:
            remote.isRight &&
            !remote.right.isFeatureEnabled &&
            local.isRight &&
            local.right.isAvailable,
      ),
    );
  }

  FutureOr<void> _mapDrawerClickEventToState(
    DrawerClickEvent event,
    Emitter<PortfolioState> emit,
  ) {
    if (event.isOpened) {
      _trackingDelegate.trackDrawerOpen();
    } else {
      _trackingDelegate.trackDrawerClose();
    }
  }

  FutureOr<void> _mapViewStateVisibleEventToState(
    ViewStateVisibleEvent event,
    Emitter<PortfolioState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }

  FutureOr<void> _mapSectionVisibleEventToState(
    SectionVisibleEvent event,
    Emitter<PortfolioState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
