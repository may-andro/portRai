import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

import '../../../../../mock/feature/notification/domain/repository/mock_notification_repository.dart';

void main() {
  group('ResetDeviceTokenUseCase', () {
    test('should delete the device token when called', () async {
      final notificationRepository = MockNotificationRepository()
        ..stubDeleteDeviceToken();

      final resetDeviceTokenEither = await ResetDeviceTokenUseCase(
        notificationRepository,
      )();

      expect(resetDeviceTokenEither.isRight, isTrue);
      verify(notificationRepository.deleteDeviceToken).called(1);
    });

    test('should return an unknown failure when deleting fails', () async {
      final notificationRepository = MockNotificationRepository();
      when(
        notificationRepository.deleteDeviceToken,
      ).thenThrow(const NotificationTokenException());

      final resetDeviceTokenEither = await ResetDeviceTokenUseCase(
        notificationRepository,
      )();

      expect(
        resetDeviceTokenEither.left,
        isA<ResetDeviceTokenUnknownFailure>(),
      );
    });
  });
}
