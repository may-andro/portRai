import 'package:portrai/src/feature/notification/domain/entity/_entity.dart';

abstract class NotificationRepository {
  /// The token that addresses this device, or null when it has none.
  Future<String?> getDeviceToken();

  /// Invalidates the token, so nothing sent to it arrives any more. The next
  /// [getDeviceToken] returns a new one.
  Future<void> deleteDeviceToken();

  /// Subscribes to the portfolio updates in [languageCode] and unsubscribes
  /// from those in every other code in [otherLanguageCodes].
  Future<void> subscribeToPortfolioUpdates({
    required String languageCode,
    required List<String> otherLanguageCodes,
  });

  /// Registers [token] as a device of [userId] that receives their
  /// notifications in [languageCode].
  Future<void> registerDevice({
    required String userId,
    required String token,
    required String languageCode,
  });

  /// New tokens issued after the token changes.
  Stream<String> get deviceTokenRefreshes;

  /// The message whose notification opened the app, or null.
  Future<PushMessageEntity?> getInitialMessage();

  /// Messages whose notification was tapped while the app was running.
  Stream<PushMessageEntity> get openedMessages;

  /// Messages received while the app is in the foreground, which the system
  /// does not display.
  Stream<PushMessageEntity> get foregroundMessages;
}
