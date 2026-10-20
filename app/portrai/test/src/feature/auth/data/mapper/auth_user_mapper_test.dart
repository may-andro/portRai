import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/auth/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/user/user.dart';

import '../../../../../mock/feature/auth/data/repository/mock_user.dart';

void main() {
  group('AuthUserMapper', () {
    const mapper = AuthUserMapper();

    test('should map the uid and email when the account has an email', () {
      final user = MockUser()
        ..stubAccount(userId: 'owner-uid', email: 'owner@example.com');

      expect(
        mapper.map(user),
        const AuthUserEntity(id: 'owner-uid', email: 'owner@example.com'),
      );
    });

    test('should map a null email when the account has none', () {
      final user = MockUser()..stubAccount(userId: 'owner-uid');

      expect(
        mapper.map(user),
        const AuthUserEntity(id: 'owner-uid', email: null),
      );
    });
  });
}
