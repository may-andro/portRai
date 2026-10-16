import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/app/restart_app.dart';
import 'package:portrai/src/feature/design_system/domain/use_case/_use_case.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_event.dart';
import 'package:portrai/src/feature/design_system/presentation/bloc/design_system_state.dart';

@register
class DesignSystemBloc extends Bloc<DesignSystemEvent, DesignSystemState> {
  DesignSystemBloc(
    this._getDesignSystemUseCase,
    this._setDesignSystemUseCase,
    this._resetDesignSystemUseCase,
  ) : super(const DesignSystemState()) {
    on<LoadDesignSystemEvent>(_mapLoadDesignSystemEventToState);
    on<DesignSystemClickEvent>(_mapDesignSystemClickEventToState);
    on<DesignSystemResetClickEvent>(_mapDesignSystemResetClickEventToState);
  }

  final GetDesignSystemUseCase _getDesignSystemUseCase;
  final SetDesignSystemUseCase _setDesignSystemUseCase;
  final ResetDesignSystemUseCase _resetDesignSystemUseCase;

  Future<void> _mapLoadDesignSystemEventToState(
    LoadDesignSystemEvent event,
    Emitter<DesignSystemState> emit,
  ) async {
    final cachedDesignSystemEither = await _getDesignSystemUseCase();
    emit(
      DesignSystemState(
        isLoaded: true,
        designSystem: cachedDesignSystemEither.right,
      ),
    );
  }

  Future<void> _mapDesignSystemClickEventToState(
    DesignSystemClickEvent event,
    Emitter<DesignSystemState> emit,
  ) async {
    final previousDesignSystem = state.designSystem;
    final setDesignSystemEither = await _setDesignSystemUseCase(
      event.designSystem,
    );
    emit(
      DesignSystemState(
        isLoaded: true,
        designSystem: setDesignSystemEither.isRight
            ? event.designSystem
            : state.designSystem,
        failure: setDesignSystemEither.isLeft
            ? setDesignSystemEither.left
            : null,
      ),
    );
    if (setDesignSystemEither.isRight &&
        state.designSystem != previousDesignSystem) {
      await restartApp();
    }
  }

  Future<void> _mapDesignSystemResetClickEventToState(
    DesignSystemResetClickEvent event,
    Emitter<DesignSystemState> emit,
  ) async {
    final resetDesignSystemEither = await _resetDesignSystemUseCase();
    emit(
      DesignSystemState(
        isLoaded: true,
        designSystem: resetDesignSystemEither.isRight
            ? null
            : state.designSystem,
        failure: resetDesignSystemEither.isLeft
            ? resetDesignSystemEither.left
            : null,
      ),
    );
    if (resetDesignSystemEither.isRight) {
      await restartApp();
    }
  }
}
