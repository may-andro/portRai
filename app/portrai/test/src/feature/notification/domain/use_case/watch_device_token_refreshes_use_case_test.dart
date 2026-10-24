import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/notification/domain/_domain.dart';

import '../../../../../mock/feature/notification/domain/repository/mock_notification_repository.dart';

void main() {
  group('WatchDeviceTokenRefreshesUseCase', () {
    test('should emit the repository values when called', () async {
      final repository = MockNotificationRepository()
        ..stubDeviceTokenRefreshes(Stream.fromIterable(['token-1', 'token-2']));

      final results = await WatchDeviceTokenRefreshesUseCase(
        repository,
      )().toList();

      expect(results.map((e) => e.right), ['token-1', 'token-2']);
    });

    test('should emit a failure when the repository stream errors', () async {
      final repository = MockNotificationRepository()
        ..stubDeviceTokenRefreshes(Stream.error(Exception('boom')));

      final results = await WatchDeviceTokenRefreshesUseCase(
        repository,
      )().toList();

      expect(
        results.single.left,
        isA<WatchDeviceTokenRefreshesUnknownFailure>(),
      );
    });
  });
}
