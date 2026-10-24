import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

import '../../../../../mock/feature/notification/domain/repository/mock_notification_repository.dart';

const _message = PushMessageEntity(
  kind: PushMessageKind.portfolioUpdate,
  title: 'Portfolio updated',
);

void main() {
  group('WatchForegroundPushMessagesUseCase', () {
    test('should emit the repository values when called', () async {
      final repository = MockNotificationRepository()
        ..stubForegroundMessages(Stream.fromIterable([_message]));

      final results = await WatchForegroundPushMessagesUseCase(
        repository,
      )().toList();

      expect(results.map((e) => e.right), [_message]);
    });

    test('should emit a failure when the repository stream errors', () async {
      final repository = MockNotificationRepository()
        ..stubForegroundMessages(Stream.error(Exception('boom')));

      final results = await WatchForegroundPushMessagesUseCase(
        repository,
      )().toList();

      expect(
        results.single.left,
        isA<WatchForegroundPushMessagesUnknownFailure>(),
      );
    });
  });
}
