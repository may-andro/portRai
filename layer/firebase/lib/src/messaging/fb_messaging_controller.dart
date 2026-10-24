import 'dart:async';

import 'package:firebase/src/messaging/fb_push_message.dart';
import 'package:firebase/src/messaging/messaging_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FbMessagingController {
  FbMessagingController(
    this._firebaseMessaging, {
    required Stream<RemoteMessage> foregroundMessages,
    required Stream<RemoteMessage> openedMessages,
    this.apnsTokenAttempts = 5,
    this.apnsTokenRetryDelay = const Duration(seconds: 1),
  }) : _foregroundMessages = foregroundMessages,
       _openedMessages = openedMessages;

  final FirebaseMessaging _firebaseMessaging;
  final Stream<RemoteMessage> _foregroundMessages;
  final Stream<RemoteMessage> _openedMessages;

  /// How often [getToken] checks for the APNs token on Apple platforms,
  /// which the system delivers shortly after the app starts.
  final int apnsTokenAttempts;
  final Duration apnsTokenRetryDelay;

  /// Messages received while the app is in the foreground. The system does
  /// not display these, so the app decides how to show them.
  Stream<FbPushMessage> get foregroundMessages =>
      _foregroundMessages.map(FbPushMessage.fromRemoteMessage);

  /// Messages whose notification was tapped while the app was in the
  /// background.
  Stream<FbPushMessage> get openedMessages =>
      _openedMessages.map(FbPushMessage.fromRemoteMessage);

  /// Asks the user to allow notifications and returns whether they are
  /// allowed, including provisional permission on Apple platforms.
  Future<bool> requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission();
      return _isAllowed(settings.authorizationStatus);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingPermissionException(error, stackTrace),
        stackTrace,
      );
    }
  }

  /// Whether notifications are allowed, without asking the user.
  Future<bool> isPermissionGranted() async {
    try {
      final settings = await _firebaseMessaging.getNotificationSettings();
      return _isAllowed(settings.authorizationStatus);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingPermissionException(error, stackTrace),
        stackTrace,
      );
    }
  }

  /// The token that addresses this installation, or null when the platform
  /// gives none. On Apple platforms it waits for the APNs token first.
  Future<String?> getToken() async {
    try {
      if (_isApplePlatform && !await _hasApnsToken()) {
        throw StateError('No APNs token after $apnsTokenAttempts attempts');
      }
      return await _firebaseMessaging.getToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingTokenException(error, stackTrace),
        stackTrace,
      );
    }
  }

  /// New tokens issued after the token from [getToken] changes.
  Stream<String> get onTokenRefresh => _firebaseMessaging.onTokenRefresh;

  /// Invalidates the current token, so messages sent to it no longer arrive.
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingTokenException(error, stackTrace),
        stackTrace,
      );
    }
  }

  /// Subscribes this installation to [topic]. Not supported on the web.
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingTopicException(topic, error, stackTrace),
        stackTrace,
      );
    }
  }

  /// Unsubscribes this installation from [topic]. Not supported on the web.
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (error, stackTrace) {
      Error.throwWithStackTrace(
        MessagingTopicException(topic, error, stackTrace),
        stackTrace,
      );
    }
  }

  /// The message whose notification opened the app from a terminated state,
  /// or null when the app was opened another way.
  Future<FbPushMessage?> getInitialMessage() async {
    final message = await _firebaseMessaging.getInitialMessage();
    return message == null ? null : FbPushMessage.fromRemoteMessage(message);
  }

  bool get _isApplePlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<bool> _hasApnsToken() async {
    for (var attempt = 1; attempt <= apnsTokenAttempts; attempt++) {
      if (await _firebaseMessaging.getAPNSToken() != null) return true;
      if (attempt < apnsTokenAttempts) {
        await Future<void>.delayed(apnsTokenRetryDelay);
      }
    }
    return false;
  }

  bool _isAllowed(AuthorizationStatus status) =>
      status == AuthorizationStatus.authorized ||
      status == AuthorizationStatus.provisional;
}
