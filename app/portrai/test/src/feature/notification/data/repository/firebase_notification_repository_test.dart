import 'package:firebase/firebase.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/data/_data.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

import '../../../../../mock/utility/mock_fb_firestore_controller.dart';
import '../../../../../mock/utility/mock_fb_messaging_controller.dart';

void main() {
  group('FirebaseNotificationRepository', () {
    late MockFbMessagingController messagingController;
    late MockFbFirestoreController firestoreController;
    late FirebaseNotificationRepository repository;

    setUp(() {
      messagingController = MockFbMessagingController()..stubTopics();
      firestoreController = MockFbFirestoreController()
        ..stubAddDocumentToCollection();
      repository = FirebaseNotificationRepository(
        messagingController,
        firestoreController,
        const PushMessageMapper(),
      );
    });

    tearDown(() => debugDefaultTargetPlatformOverride = null);

    Future<void> registerDevice({String languageCode = 'es'}) =>
        repository.registerDevice(
          userId: 'owner-uid',
          token: 'device-token',
          languageCode: languageCode,
        );

    test('should subscribe to the language topic and unsubscribe from the '
        'others when subscribing', () async {
      await repository.subscribeToPortfolioUpdates(
        languageCode: 'es',
        otherLanguageCodes: ['en', 'nl'],
      );

      verifyInOrder([
        () => messagingController.subscribeToTopic('portfolio_updates_es'),
        () => messagingController.unsubscribeFromTopic('portfolio_updates_en'),
        () => messagingController.unsubscribeFromTopic('portfolio_updates_nl'),
      ]);
    });

    test('should not subscribe again when the language is unchanged', () async {
      for (var attempt = 0; attempt < 2; attempt++) {
        await repository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: ['en'],
        );
      }

      verify(
        () => messagingController.subscribeToTopic('portfolio_updates_es'),
      ).called(1);
    });

    test('should throw a topic exception when subscribing fails', () async {
      messagingController.stubSubscribeToTopicThrows(StateError('offline'));

      await expectLater(
        repository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: [],
        ),
        throwsA(isA<NotificationTopicException>()),
      );
    });

    test('should write the device under the user when registering', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      await registerDevice();

      final data =
          verify(
                () => firestoreController.addDocumentToCollection(
                  collectionPath: 'users/owner-uid/devices',
                  documentPath: 'device-token',
                  data: captureAny(named: 'data'),
                ),
              ).captured.single
              as Map<String, dynamic>;
      expect(data['locale'], 'es');
      expect(data['platform'], 'ios');
      expect(data['updatedAt'], isA<FieldValue>());
    });

    test('should register again only when the language changes', () async {
      await registerDevice();
      await registerDevice();
      await registerDevice(languageCode: 'nl');

      verify(
        () => firestoreController.addDocumentToCollection(
          collectionPath: any(named: 'collectionPath'),
          documentPath: any(named: 'documentPath'),
          data: any(named: 'data'),
        ),
      ).called(2);
    });

    test(
      'should subscribe and register again after the token is deleted',
      () async {
        messagingController.stubDeleteToken();
        await repository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: [],
        );
        await registerDevice();

        await repository.deleteDeviceToken();
        await repository.subscribeToPortfolioUpdates(
          languageCode: 'es',
          otherLanguageCodes: [],
        );
        await registerDevice();

        verify(
          () => messagingController.subscribeToTopic('portfolio_updates_es'),
        ).called(2);
        verify(
          () => firestoreController.addDocumentToCollection(
            collectionPath: any(named: 'collectionPath'),
            documentPath: any(named: 'documentPath'),
            data: any(named: 'data'),
          ),
        ).called(2);
      },
    );

    test('should throw a device exception when the write fails', () async {
      firestoreController.stubAddDocumentToCollectionThrows(
        StateError('denied'),
      );

      await expectLater(
        registerDevice(),
        throwsA(isA<NotificationDeviceException>()),
      );
    });

    test(
      'should throw a token exception when reading the token fails',
      () async {
        messagingController.stubGetTokenThrows(StateError('no APNs'));

        await expectLater(
          repository.getDeviceToken(),
          throwsA(isA<NotificationTokenException>()),
        );
      },
    );

    test('should map the initial and opened messages', () async {
      const message = FbPushMessage(data: {'kind': 'job_openings'});
      messagingController
        ..stubInitialMessage(message)
        ..stubOpenedMessages(Stream.value(message));

      expect(
        await repository.getInitialMessage(),
        const PushMessageEntity(kind: PushMessageKind.jobOpenings),
      );
      expect(
        await repository.openedMessages.single,
        const PushMessageEntity(kind: PushMessageKind.jobOpenings),
      );
    });
  });
}
