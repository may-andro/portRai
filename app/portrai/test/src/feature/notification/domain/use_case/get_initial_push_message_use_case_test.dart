import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

import '../../../../../mock/feature/notification/domain/repository/mock_notification_repository.dart';

void main() {
  group('GetInitialPushMessageUseCase', () {
    test(
      'should return the message when a notification opened the app',
      () async {
        const message = PushMessageEntity(kind: PushMessageKind.jobOpenings);
        final notificationRepository = MockNotificationRepository()
          ..stubGetInitialMessage(message);

        final initialMessageEither = await GetInitialPushMessageUseCase(
          notificationRepository,
        )();

        expect(initialMessageEither.right, message);
      },
    );

    test('should return an unknown failure when reading fails', () async {
      final notificationRepository = MockNotificationRepository();
      when(
        notificationRepository.getInitialMessage,
      ).thenThrow(StateError('broken'));

      final initialMessageEither = await GetInitialPushMessageUseCase(
        notificationRepository,
      )();

      expect(
        initialMessageEither.left,
        isA<GetInitialPushMessageUnknownFailure>(),
      );
    });
  });
}
