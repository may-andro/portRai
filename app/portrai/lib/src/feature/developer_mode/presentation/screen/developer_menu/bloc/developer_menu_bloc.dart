import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_event.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/developer_menu_state.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/tracking/_tracking.dart';

@register
class DeveloperMenuBloc extends Bloc<DeveloperMenuEvent, DeveloperMenuState> {
  DeveloperMenuBloc(this._trackingDelegate)
    : super(const DeveloperMenuInitialState()) {
    on<LoadDeveloperMenuEvent>(_onLoad);
    on<ForceFatalCrashEvent>(_onForceFatalCrash);
    on<ForceNonFatalCrashEvent>(_onForceNonFatalCrash);
    on<ForceBlacklistErrorEvent>(_onForceBlacklistError);
    on<ScreenVisibleEvent>(_onScreenVisible);
    on<ViewStateVisibleEvent>(_onViewStateVisible);
  }

  final DeveloperMenuTrackingDelegate _trackingDelegate;

  void _onLoad(LoadDeveloperMenuEvent event, Emitter<DeveloperMenuState> emit) {
    emit(const DeveloperMenuLoadedState());
  }

  void _onForceFatalCrash(
    ForceFatalCrashEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle fatal crash
  }

  void _onForceNonFatalCrash(
    ForceNonFatalCrashEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle non-fatal crash
  }

  void _onForceBlacklistError(
    ForceBlacklistErrorEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    // Handle blacklist error
  }

  void _onScreenVisible(
    ScreenVisibleEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    _trackingDelegate.trackScreenView();
  }

  void _onViewStateVisible(
    ViewStateVisibleEvent event,
    Emitter<DeveloperMenuState> emit,
  ) {
    _trackingDelegate.trackViewEvent(event.trackingId);
  }
}
