import 'package:firebase/firebase.dart' as firebase;
import 'package:flutter/foundation.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/notification/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/notification/data/model/_model.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

// A singleton, so a run subscribes and registers again only when something
// changed.
@RegisterSingleton(as: NotificationRepository)
class FirebaseNotificationRepository implements NotificationRepository {
  FirebaseNotificationRepository(
    this._messagingController,
    this._firestoreController,
    this._pushMessageMapper,
  );

  final firebase.FbMessagingController _messagingController;
  final firebase.FbFirestoreController _firestoreController;
  final PushMessageMapper _pushMessageMapper;

  String? _subscribedLanguageCode;
  String? _registeredDeviceKey;

  /// The topic the portfolio update function sends to for [languageCode].
  static String portfolioUpdatesTopic(String languageCode) =>
      'portfolio_updates_$languageCode';

  @override
  Future<String?> getDeviceToken() async {
    try {
      return await _messagingController.getToken();
    } catch (error, stackTrace) {
      throw NotificationTokenException(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> deleteDeviceToken() async {
    try {
      await _messagingController.deleteToken();
      // Topics and registrations belonged to the old token.
      _subscribedLanguageCode = null;
      _registeredDeviceKey = null;
    } catch (error, stackTrace) {
      throw NotificationTokenException(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> subscribeToPortfolioUpdates({
    required String languageCode,
    required List<String> otherLanguageCodes,
  }) async {
    if (_subscribedLanguageCode == languageCode) return;
    try {
      await _messagingController.subscribeToTopic(
        portfolioUpdatesTopic(languageCode),
      );
      for (final otherLanguageCode in otherLanguageCodes) {
        await _messagingController.unsubscribeFromTopic(
          portfolioUpdatesTopic(otherLanguageCode),
        );
      }
      _subscribedLanguageCode = languageCode;
    } catch (error, stackTrace) {
      throw NotificationTopicException(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  Future<void> registerDevice({
    required String userId,
    required String token,
    required String languageCode,
  }) async {
    final deviceKey = '$userId/$token/$languageCode';
    if (_registeredDeviceKey == deviceKey) return;
    try {
      await _firestoreController.addDocumentToCollection(
        collectionPath: 'users/$userId/devices',
        documentPath: token,
        data: {
          ...NotificationDeviceModel(
            locale: languageCode,
            platform: _platform,
          ).toJson(),
          // Set by Firestore, so a wrong device clock cannot change it.
          'updatedAt': firebase.FieldValue.serverTimestamp(),
        },
      );
      _registeredDeviceKey = deviceKey;
    } catch (error, stackTrace) {
      throw NotificationDeviceException(cause: error, stackTrace: stackTrace);
    }
  }

  @override
  Stream<String> get deviceTokenRefreshes =>
      _messagingController.onTokenRefresh;

  @override
  Future<PushMessageEntity?> getInitialMessage() async {
    final message = await _messagingController.getInitialMessage();
    return message == null ? null : _pushMessageMapper.map(message);
  }

  @override
  Stream<PushMessageEntity> get openedMessages =>
      _messagingController.openedMessages.map(_pushMessageMapper.map);

  @override
  Stream<PushMessageEntity> get foregroundMessages =>
      _messagingController.foregroundMessages.map(_pushMessageMapper.map);

  static String get _platform => kIsWeb
      ? 'web'
      : switch (defaultTargetPlatform) {
          TargetPlatform.iOS => 'ios',
          _ => 'android',
        };
}
