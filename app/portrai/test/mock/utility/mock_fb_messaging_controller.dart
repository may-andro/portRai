import 'package:firebase/firebase.dart';
import 'package:mocktail/mocktail.dart';

class MockFbMessagingController extends Mock implements FbMessagingController {}

extension MockFbMessagingControllerStub on MockFbMessagingController {
  void stubGetToken(String? token) {
    when(getToken).thenAnswer((_) async => token);
  }

  void stubGetTokenThrows(Object error) {
    when(getToken).thenThrow(error);
  }

  void stubDeleteToken() {
    when(deleteToken).thenAnswer((_) async {});
  }

  void stubTopics() {
    when(() => subscribeToTopic(any())).thenAnswer((_) async {});
    when(() => unsubscribeFromTopic(any())).thenAnswer((_) async {});
  }

  void stubSubscribeToTopicThrows(Object error) {
    when(() => subscribeToTopic(any())).thenThrow(error);
  }

  void stubInitialMessage(FbPushMessage? message) {
    when(getInitialMessage).thenAnswer((_) async => message);
  }

  void stubOpenedMessages(Stream<FbPushMessage> messages) {
    when(() => openedMessages).thenAnswer((_) => messages);
  }
}
