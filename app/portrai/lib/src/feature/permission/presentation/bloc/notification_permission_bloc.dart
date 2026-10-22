import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/permission/domain/_domain.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/notification_permission_event.dart';
import 'package:portrai/src/feature/permission/presentation/bloc/notification_permission_state.dart';

/// Mirrors the system's notification permission for the app. Turning it on
/// shows the system prompt while the system still offers one, and otherwise
/// opens the app's page in the device settings; turning it off opens that
/// page, because an app cannot withdraw its own permission.
@register
class NotificationPermissionBloc
    extends Bloc<NotificationPermissionEvent, NotificationPermissionState> {
  NotificationPermissionBloc(
    this._getPermissionStatusUseCase,
    this._requestPermissionUseCase,
    this._openPermissionSettingsUseCase,
  ) : super(const NotificationPermissionState()) {
    on<NotificationPermissionVisibleEvent>(
      _mapNotificationPermissionVisibleEventToState,
    );
    on<NotificationPermissionToggleClickEvent>(
      _mapNotificationPermissionToggleClickEventToState,
    );
  }

  final GetPermissionStatusUseCase _getPermissionStatusUseCase;
  final RequestPermissionUseCase _requestPermissionUseCase;
  final OpenPermissionSettingsUseCase _openPermissionSettingsUseCase;

  Future<void> _mapNotificationPermissionVisibleEventToState(
    NotificationPermissionVisibleEvent event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    final statusEither = await _getPermissionStatusUseCase(
      AppPermission.notifications,
    );
    emit(
      statusEither.isRight
          ? NotificationPermissionState(status: statusEither.right)
          : NotificationPermissionState(
              status: state.status,
              failure: statusEither.left,
            ),
    );
  }

  Future<void> _mapNotificationPermissionToggleClickEventToState(
    NotificationPermissionToggleClickEvent event,
    Emitter<NotificationPermissionState> emit,
  ) async {
    if (event.enabled && state.status == AppPermissionStatus.denied) {
      final statusEither = await _requestPermissionUseCase(
        AppPermission.notifications,
      );
      if (statusEither.isLeft) {
        emit(
          NotificationPermissionState(
            status: state.status,
            failure: statusEither.left,
          ),
        );
        return;
      }
      emit(NotificationPermissionState(status: statusEither.right));
      return;
    }
    // The system no longer prompts, or the user is turning notifications
    // off: only the device settings can change it. The status is read again
    // when the user returns.
    final openSettingsEither = await _openPermissionSettingsUseCase();
    if (openSettingsEither.isLeft) {
      emit(
        NotificationPermissionState(
          status: state.status,
          failure: openSettingsEither.left,
        ),
      );
    }
  }
}
