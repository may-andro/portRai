import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../mock/feature/auth/domain/repository/mock_auth_repository.dart';

void main() {
  group('WatchSignedInUserUseCase', () {
    test('should emit the repository changes when called', () async {
      const user = AuthUserEntity(id: 'owner-uid', email: null);
      final authRepository = MockAuthRepository()
        ..stubSignedInUserChanges(Stream.fromIterable([null, user]));

      final results = await WatchSignedInUserUseCase(authRepository)().toList();

      expect(results.map((e) => e.right), [null, user]);
    });

    test('should emit a failure when the repository stream errors', () async {
      final authRepository = MockAuthRepository()
        ..stubSignedInUserChanges(Stream.error(Exception('boom')));

      final results = await WatchSignedInUserUseCase(authRepository)().toList();

      expect(results.single.left, isA<WatchSignedInUserUnknownFailure>());
    });
  });
}
