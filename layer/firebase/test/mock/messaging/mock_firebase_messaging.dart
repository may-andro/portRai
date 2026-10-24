import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:mocktail/mocktail.dart';

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

extension MockFirebaseMessagingStub on MockFirebaseMessaging {
  void stubRequestPermission(AuthorizationStatus status, {Object? error}) {
    when(requestPermission).thenAnswer((_) async {
      if (error != null) throw error;
      return _settings(status);
    });
  }

  void stubNotificationSettings(AuthorizationStatus status) {
    when(getNotificationSettings).thenAnswer((_) async => _settings(status));
  }

  void stubGetToken(String? token, {Object? error}) {
    when(getToken).thenAnswer((_) async {
      if (error != null) throw error;
      return token;
    });
  }

  /// Answers [getAPNSToken] with [tokens] in turn, then with the last one.
  void stubApnsTokens(List<String?> tokens) {
    var call = 0;
    when(getAPNSToken).thenAnswer(
      (_) async => tokens[call < tokens.length ? call++ : tokens.length - 1],
    );
  }

  void stubDeleteToken({Object? error}) {
    when(deleteToken).thenAnswer((_) async {
      if (error != null) throw error;
    });
  }

  void stubTopics({Object? error}) {
    when(() => subscribeToTopic(any())).thenAnswer((_) async {
      if (error != null) throw error;
    });
    when(() => unsubscribeFromTopic(any())).thenAnswer((_) async {
      if (error != null) throw error;
    });
  }

  void stubInitialMessage(RemoteMessage? message) {
    when(getInitialMessage).thenAnswer((_) async => message);
  }

  NotificationSettings _settings(AuthorizationStatus status) {
    return NotificationSettings(
      alert: AppleNotificationSetting.enabled,
      announcement: AppleNotificationSetting.notSupported,
      authorizationStatus: status,
      badge: AppleNotificationSetting.enabled,
      carPlay: AppleNotificationSetting.notSupported,
      lockScreen: AppleNotificationSetting.enabled,
      notificationCenter: AppleNotificationSetting.enabled,
      showPreviews: AppleShowPreviewSetting.always,
      timeSensitive: AppleNotificationSetting.notSupported,
      criticalAlert: AppleNotificationSetting.notSupported,
      sound: AppleNotificationSetting.enabled,
      providesAppNotificationSettings: AppleNotificationSetting.notSupported,
    );
  }
}
