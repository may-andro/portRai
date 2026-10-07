import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';

import '../../../../../mock/feature/connectivity/domain/repository/mock_connectivity_repository.dart';

void main() {
  group('WatchInternetConnectionUseCase', () {
    test('should emit the repository values when called', () async {
      final repository = MockConnectivityRepository()
        ..stubWatchConnection(Stream.fromIterable([false, true]));

      final results = await WatchInternetConnectionUseCase(
        repository,
      )().toList();

      expect(results.map((e) => e.right), [false, true]);
    });

    test('should emit a failure when the repository stream errors', () async {
      final repository = MockConnectivityRepository()
        ..stubWatchConnection(Stream.error(Exception('boom')));

      final results = await WatchInternetConnectionUseCase(
        repository,
      )().toList();

      expect(results.single.left, isA<WatchInternetConnectionUnknownFailure>());
    });
  });
}
