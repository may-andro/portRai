import 'dart:async';

import 'package:firebase/src/messaging/fb_messaging_controller.dart';
import 'package:firebase/src/messaging/fb_push_message.dart';
import 'package:firebase/src/messaging/messaging_exception.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mock/messaging/mock_firebase_messaging.dart';

const _message = RemoteMessage(
  notification: RemoteNotification(title: 'Title', body: 'Body'),
  data: {'route': '/items', 'count': 3},
);

const _pushMessage = FbPushMessage(
  title: 'Title',
  body: 'Body',
  data: {'route': '/items', 'count': '3'},
);

void main() {
  group(FbMessagingController, () {
    late MockFirebaseMessaging messaging;
    late StreamController<RemoteMessage> foregroundMessages;
    late StreamController<RemoteMessage> openedMessages;
    late FbMessagingController controller;

    setUp(() {
      messaging = MockFirebaseMessaging();
      foregroundMessages = StreamController<RemoteMessage>.broadcast();
      openedMessages = StreamController<RemoteMessage>.broadcast();
      controller = FbMessagingController(
        messaging,
        foregroundMessages: foregroundMessages.stream,
        openedMessages: openedMessages.stream,
        apnsTokenAttempts: 3,
        apnsTokenRetryDelay: Duration.zero,
      );
    });

    tearDown(() async {
      debugDefaultTargetPlatformOverride = null;
      await foregroundMessages.close();
      await openedMessages.close();
    });

    for (final (status, isAllowed) in [
      (AuthorizationStatus.authorized, true),
      (AuthorizationStatus.provisional, true),
      (AuthorizationStatus.denied, false),
      (AuthorizationStatus.notDetermined, false),
    ]) {
      test(
        'should return $isAllowed when the permission request ends $status',
        () async {
          messaging.stubRequestPermission(status);

          expect(await controller.requestPermission(), isAllowed);
        },
      );

      test(
        'should return $isAllowed when the current permission is $status',
        () async {
          messaging.stubNotificationSettings(status);

          expect(await controller.isPermissionGranted(), isAllowed);
          verifyNever(messaging.requestPermission);
        },
      );
    }

    test(
      'should throw a permission exception when the request fails',
      () async {
        final error = StateError('permission failed');
        messaging.stubRequestPermission(
          AuthorizationStatus.denied,
          error: error,
        );

        await expectLater(
          controller.requestPermission(),
          throwsA(
            isA<MessagingPermissionException>().having(
              (exception) => exception.cause,
              'cause',
              same(error),
            ),
          ),
        );
      },
    );

    test(
      'should return the token without waiting for APNs when not on Apple',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.android;
        messaging.stubGetToken('device-token');

        expect(await controller.getToken(), 'device-token');
        verifyNever(messaging.getAPNSToken);
      },
    );

    test(
      'should wait for the APNs token when on iOS before reading the token',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        messaging
          ..stubApnsTokens([null, 'apns-token'])
          ..stubGetToken('device-token');

        expect(await controller.getToken(), 'device-token');
        verify(messaging.getAPNSToken).called(2);
      },
      skip: kIsWeb,
    );

    test(
      'should throw a token exception when iOS never gets an APNs token',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        messaging.stubApnsTokens([null]);

        await expectLater(
          controller.getToken(),
          throwsA(isA<MessagingTokenException>()),
        );
        verify(messaging.getAPNSToken).called(3);
        verifyNever(messaging.getToken);
      },
      skip: kIsWeb,
    );

    test('should throw a token exception when deleting fails', () async {
      final error = StateError('delete failed');
      messaging.stubDeleteToken(error: error);

      await expectLater(
        controller.deleteToken(),
        throwsA(
          isA<MessagingTokenException>().having(
            (exception) => exception.cause,
            'cause',
            same(error),
          ),
        ),
      );
    });

    test(
      'should forward the topic when subscribing and unsubscribing',
      () async {
        messaging.stubTopics();

        await controller.subscribeToTopic('updates');
        await controller.unsubscribeFromTopic('updates');

        verifyInOrder([
          () => messaging.subscribeToTopic('updates'),
          () => messaging.unsubscribeFromTopic('updates'),
        ]);
      },
    );

    test('should throw a topic exception when subscribing fails', () async {
      messaging.stubTopics(error: StateError('topic failed'));

      await expectLater(
        controller.subscribeToTopic('updates'),
        throwsA(
          isA<MessagingTopicException>().having(
            (exception) => exception.message,
            'message',
            contains('updates'),
          ),
        ),
      );
    });

    test(
      'should map the message when the app was opened from a notification',
      () async {
        messaging.stubInitialMessage(_message);

        expect(await controller.getInitialMessage(), _pushMessage);
      },
    );

    test(
      'should return null when the app was not opened from a notification',
      () async {
        messaging.stubInitialMessage(null);

        expect(await controller.getInitialMessage(), isNull);
      },
    );

    test(
      'should map messages when they arrive in the foreground or are opened',
      () async {
        final foreground = expectLater(
          controller.foregroundMessages,
          emits(_pushMessage),
        );
        final opened = expectLater(
          controller.openedMessages,
          emits(_pushMessage),
        );

        foregroundMessages.add(_message);
        openedMessages.add(_message);

        await Future.wait([foreground, opened]);
      },
    );
  });
}
