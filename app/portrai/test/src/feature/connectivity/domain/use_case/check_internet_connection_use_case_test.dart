import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/connectivity/domain/_domain.dart';

import '../../../../../mock/feature/connectivity/domain/repository/mock_connectivity_repository.dart';

void main() {
  group('CheckInternetConnectionUseCase', () {
    late MockConnectivityRepository repository;
    late CheckInternetConnectionUseCase useCase;

    setUp(() {
      repository = MockConnectivityRepository();
      useCase = CheckInternetConnectionUseCase(repository);
    });

    test('should return true when the repository is connected', () async {
      repository.stubIsConnected(true);

      final result = await useCase();

      expect(result.right, isTrue);
    });

    test('should return false when the repository is not connected', () async {
      repository.stubIsConnected(false);

      final result = await useCase();

      expect(result.right, isFalse);
    });

    test('should return a failure when the repository throws', () async {
      when(repository.isConnected).thenThrow(Exception('boom'));

      final result = await useCase();

      expect(result.left, isA<CheckInternetConnectionUnknownFailure>());
    });
  });
}
