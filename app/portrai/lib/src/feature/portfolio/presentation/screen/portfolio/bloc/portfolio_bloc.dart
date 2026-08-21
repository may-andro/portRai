import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/portfolio/domain/_domain.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_event.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/bloc/portfolio_state.dart';
import 'package:portrai/src/feature/portfolio/presentation/screen/portfolio/tracking/_tracking.dart';
import 'package:use_case/use_case.dart';

@register
class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  PortfolioBloc(this._getPortfolioUseCase, this._trackingDelegate)
    : super(const LoadingState()) {
    on<LoadPortfolioEvent>(_mapLoadPortfolioEventToState);
    on<ScreenVisibleEvent>(_mapScreenVisibleEventToState);
    on<DrawerClickEvent>(_mapDrawerClickEventToState);
    on<SectionNavigationEvent>(_mapSectionNavigationEventToState);
    on<ViewStateVisibleEvent>(_mapViewStateVisibleEventToState);
    on<SectionVisibleEvent>(_mapSectionVisibleEventToState);
  }

  final GetPortfolioUseCase _getPortfolioUseCase;
  final PortfolioTrackingDelegate _trackingDelegate;

  Future<void> _mapLoadPortfolioEventToState(
    LoadPortfolioEvent event,
    Emitter<PortfolioState> emit,
  ) async {
    emit(const LoadingState());
    try {
      final result = await _getPortfolioUseCase();
      result.fold(
        (failure) {
          emit(ErrorState(failure));
        },
        (portfolio) {
          emit(LoadedState(portfolio: portfolio));
        },
      );
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
  void _mapScreenVisibleEventToState(
    ScreenVisibleEvent event,
    Emitter<PortfolioState> emit,
  ) {
    _trackingDelegate.trackScreenView();
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
