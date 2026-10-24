import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/auth/domain/_domain.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../mock/feature/auth/domain/repository/mock_auth_repository.dart';

void main() {
  group('GetSignedInUserStreamUseCase', () {
    test('should emit the repository changes when called', () async {
      const user = AuthUserEntity(id: 'owner-uid', email: null);
      final authRepository = MockAuthRepository()
        ..stubSignedInUserChanges(Stream.fromIterable([null, user]));

      final users = await GetSignedInUserStreamUseCase(
        authRepository,
      )().toList();

      expect(users, [null, user]);
    });
  });
}
