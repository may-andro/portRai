import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/auth/auth.dart';
import 'package:portrai/src/feature/locale/locale.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/notification_listener_event.dart';
import 'package:portrai/src/feature/notification/presentation/bloc/notification_listener_state.dart';

/// Keeps this device's notifications in step with the app for as long as it
/// runs, and reports the notifications the user taps or receives in the
/// foreground. When a user signs out, the device token is replaced, so their
/// notifications stop reaching this device.
@register
class NotificationListenerBloc
    extends Bloc<NotificationListenerEvent, NotificationListenerState> {
  NotificationListenerBloc(
    this._syncNotificationsUseCase,
    this._resetDeviceTokenUseCase,
    this._getInitialPushMessageUseCase,
    this._getOpenedPushMessageStreamUseCase,
    this._getForegroundPushMessageStreamUseCase,
    this._getDeviceTokenRefreshStreamUseCase,
    this._getLocaleStreamUseCase,
    this._getSignedInUserStreamUseCase,
  ) : super(const NotificationListenerIdleState()) {
    on<NotificationListenerStartEvent>(
      _mapNotificationListenerStartEventToState,
    );
    on<NotificationsSyncRequestedEvent>(
      _mapNotificationsSyncRequestedEventToState,
    );
    on<SignedInStatusChangedEvent>(_mapSignedInStatusChangedEventToState);
    on<PushMessageOpenedEvent>(_mapPushMessageOpenedEventToState);
    on<PushMessageReceivedEvent>(_mapPushMessageReceivedEventToState);
  }

  final SyncNotificationsUseCase _syncNotificationsUseCase;
  final ResetDeviceTokenUseCase _resetDeviceTokenUseCase;
  final GetInitialPushMessageUseCase _getInitialPushMessageUseCase;
  final GetOpenedPushMessageStreamUseCase _getOpenedPushMessageStreamUseCase;
  final GetForegroundPushMessageStreamUseCase
  _getForegroundPushMessageStreamUseCase;
  final GetDeviceTokenRefreshStreamUseCase _getDeviceTokenRefreshStreamUseCase;
  final GetLocaleStreamUseCase _getLocaleStreamUseCase;
  final GetSignedInUserStreamUseCase _getSignedInUserStreamUseCase;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  List<String> _supportedLanguageCodes = const [];
  bool? _isSignedIn;
  int _sequence = 0;

  // Syncs run one after another, so two cannot subscribe or register at once.
  Future<void> _pendingSync = Future.value();

  Future<void> _mapNotificationListenerStartEventToState(
    NotificationListenerStartEvent event,
    Emitter<NotificationListenerState> emit,
  ) async {
    _supportedLanguageCodes = event.supportedLanguageCodes;
    _subscriptions.addAll([
      _getOpenedPushMessageStreamUseCase().listen(
        (message) => add(PushMessageOpenedEvent(message)),
      ),
      _getForegroundPushMessageStreamUseCase().listen(
        (message) => add(PushMessageReceivedEvent(message)),
      ),
      _getDeviceTokenRefreshStreamUseCase().listen(
        (_) => add(const NotificationsSyncRequestedEvent()),
      ),
      _getLocaleStreamUseCase().listen(
        (_) => add(const NotificationsSyncRequestedEvent()),
      ),
      // The first event is the restored session, which also starts the
      // first sync.
      _getSignedInUserStreamUseCase().listen(
        (user) => add(SignedInStatusChangedEvent(isSignedIn: user != null)),
      ),
    ]);

    final initialMessageEither = await _getInitialPushMessageUseCase();
    if (initialMessageEither.isRight) {
      if (initialMessageEither.right case final message?) {
        emit(PushMessageOpenedState(message, ++_sequence));
      }
    }
  }

  Future<void> _mapNotificationsSyncRequestedEventToState(
    NotificationsSyncRequestedEvent event,
    Emitter<NotificationListenerState> emit,
  ) => _sync();

  Future<void> _mapSignedInStatusChangedEventToState(
    SignedInStatusChangedEvent event,
    Emitter<NotificationListenerState> emit,
  ) async {
    final wasSignedIn = _isSignedIn ?? false;
    _isSignedIn = event.isSignedIn;
    if (wasSignedIn && !event.isSignedIn) {
      // The signed-out user's registration holds the old token. Replacing
      // it means their notifications no longer arrive here; the next send
      // to it also removes the registration.
      _pendingSync = _pendingSync.then((_) => _resetDeviceTokenUseCase());
    }
    await _sync();
  }

  void _mapPushMessageOpenedEventToState(
    PushMessageOpenedEvent event,
    Emitter<NotificationListenerState> emit,
  ) => emit(PushMessageOpenedState(event.message, ++_sequence));

  void _mapPushMessageReceivedEventToState(
    PushMessageReceivedEvent event,
    Emitter<NotificationListenerState> emit,
  ) => emit(PushMessageReceivedState(event.message, ++_sequence));

  Future<void> _sync() => _pendingSync = _pendingSync.then(
    (_) => _syncNotificationsUseCase(_supportedLanguageCodes),
  );

  @override
  Future<void> close() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await super.close();
  }
}
