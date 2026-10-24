import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

class MockNotificationRepository extends Mock
    implements NotificationRepository {}

extension MockNotificationRepositoryStub on MockNotificationRepository {
  void stubGetDeviceToken(String? token) {
    when(getDeviceToken).thenAnswer((_) async => token);
  }

  void stubGetDeviceTokenThrows(Object error) {
    when(getDeviceToken).thenThrow(error);
  }

  void stubDeleteDeviceToken() {
    when(deleteDeviceToken).thenAnswer((_) async {});
  }

  void stubSubscribeToPortfolioUpdates() {
    when(
      () => subscribeToPortfolioUpdates(
        languageCode: any(named: 'languageCode'),
        otherLanguageCodes: any(named: 'otherLanguageCodes'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubRegisterDevice() {
    when(
      () => registerDevice(
        userId: any(named: 'userId'),
        token: any(named: 'token'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenAnswer((_) async {});
  }

  void stubRegisterDeviceThrows(Object error) {
    when(
      () => registerDevice(
        userId: any(named: 'userId'),
        token: any(named: 'token'),
        languageCode: any(named: 'languageCode'),
      ),
    ).thenThrow(error);
  }

  void stubGetInitialMessage(PushMessageEntity? message) {
    when(getInitialMessage).thenAnswer((_) async => message);
  }
}
