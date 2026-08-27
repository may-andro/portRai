import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/external_app_handler/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/domain/_domain.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_event.dart';
import 'package:portrai/src/feature/force_update/presentation/bloc/force_update_state.dart';
import 'package:portrai/src/feature/force_update/presentation/tracking/_tracking.dart';

@register
class ForceUpdateBloc extends Bloc<ForceUpdateEvent, ForceUpdateState> {
  ForceUpdateBloc({
    required IsAppUpdateRequiredUseCase isAppUpdateRequiredUseCase,
    required GetAppStoreUrlUseCase getAppStoreUrlUseCase,
    required OpenExternalUrlUseCase openExternalUrlUseCase,
    required ForceUpdateTrackingDelegate trackingDelegate,
  }) : _isAppUpdateRequiredUseCase = isAppUpdateRequiredUseCase,
       _getAppStoreUrlUseCase = getAppStoreUrlUseCase,
       _openExternalUrlUseCase = openExternalUrlUseCase,
       _trackingDelegate = trackingDelegate,
       super(const ForceUpdateInitialState()) {
    on<CheckForceUpdateEvent>(_onCheckForceUpdateEventToState);
    on<UpdateNowClickEvent>(_onUpdateNowClickEventToState);
  }

  final IsAppUpdateRequiredUseCase _isAppUpdateRequiredUseCase;
  final GetAppStoreUrlUseCase _getAppStoreUrlUseCase;
  final OpenExternalUrlUseCase _openExternalUrlUseCase;
  final ForceUpdateTrackingDelegate _trackingDelegate;

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

    if (isUpdateRequired) {
      _trackingDelegate.trackScreenView();
    }

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
    _trackingDelegate.trackUpdateNowClick();

    final storeUrlEither = await _getAppStoreUrlUseCase();

    if (storeUrlEither.isLeft) {
      _trackingDelegate.trackLaunchFailedView();
      emit(ForceUpdateLaunchFailedState(failure: storeUrlEither.left));
      return;
    }

    final openResult = await _openExternalUrlUseCase(
      OpenExternalUrlParam(storeUrlEither.right),
    );

    if (openResult.isLeft) {
      _trackingDelegate.trackLaunchFailedView();
      emit(ForceUpdateLaunchFailedState(failure: openResult.left));
    }
  }
}
