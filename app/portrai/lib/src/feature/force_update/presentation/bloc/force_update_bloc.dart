import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_event.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_state.dart';

@register
class ForceUpdateBloc extends Bloc<ForceUpdateEvent, ForceUpdateState> {
  ForceUpdateBloc({
    required IsAppUpdateRequiredUseCase isAppUpdateRequiredUseCase,
    required GetAppStoreUrlUseCase getAppStoreUrlUseCase,
    required OpenExternalUrlUseCase openExternalUrlUseCase,
  }) : _isAppUpdateRequiredUseCase = isAppUpdateRequiredUseCase,
       _getAppStoreUrlUseCase = getAppStoreUrlUseCase,
       _openExternalUrlUseCase = openExternalUrlUseCase,
       super(const ForceUpdateInitialState()) {
    on<CheckForceUpdateEvent>(_onCheckForceUpdateEventToState);
    on<UpdateNowClickEvent>(_onUpdateNowClickEventToState);
  }

  final IsAppUpdateRequiredUseCase _isAppUpdateRequiredUseCase;
  final GetAppStoreUrlUseCase _getAppStoreUrlUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;

  Future<void> _onCheckForceUpdateEventToState(
    CheckForceUpdateEvent event,
    Emitter<ForceUpdateState> emit,
  ) async {
    final isUpdateRequiredEither = await _isAppUpdateRequiredUseCase();

    // If the check itself fails, don't block the app - the failure is
    // already logged by LogUseCaseInterceptor.
    final isUpdateRequired = isUpdateRequiredEither.fold(
      (_) => false,
      (isUpdateRequired) => isUpdateRequired,
    );

    emit(
      isUpdateRequired
          ? const ForceUpdateRequiredState()
          : const ForceUpdateNotRequiredState(),
    );
  }

  Future<void> _onUpdateNowClickEventToState(
    UpdateNowClickEvent event,
    Emitter<ForceUpdateState> emit,
  ) async {
    final storeUrlEither = await _getAppStoreUrlUseCase();

    if (storeUrlEither.isLeft) {
      emit(ForceUpdateLaunchFailedState(failure: storeUrlEither.left));
      return;
    }

    final openResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(storeUrlEither.right),
    );

    if (openResult.isLeft) {
      emit(ForceUpdateLaunchFailedState(failure: openResult.left));
    }
  }
}
