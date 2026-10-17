import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/onboarding/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';
import 'package:portrai/src/feature/onboarding/data/repository/_repository.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

import '../../../../../mock/feature/onboarding/data/cache/mock_user_cache.dart';

class _FakeUserModel extends Fake implements UserModel {}

void main() {
  setUpAll(() => registerFallbackValue(_FakeUserModel()));

  group('UserRepositoryImpl', () {
    late MockUserCache cache;
    late UserRepositoryImpl repository;

    setUp(() {
      cache = MockUserCache();
      repository = UserRepositoryImpl(cache, const UserMapper());
    });

    test('should return the mapped user when the cache has one', () async {
      cache.stubGet(const UserModel(role: 'developer'));

      final user = await repository.getUser();

      expect(user, const UserEntity(role: UserRole.developer));
    });

    test('should return null when the cache is empty', () async {
      cache.stubGet(null);

      expect(await repository.getUser(), isNull);
    });

    test('should return null when the cache read throws', () async {
      cache.stubGetThrows(StateError('broken'));

      expect(await repository.getUser(), isNull);
    });

    test('should return null when the cached role is unknown', () async {
      cache.stubGet(const UserModel(role: 'astronaut'));

      expect(await repository.getUser(), isNull);
    });

    test('should store the mapped model when saving a user', () async {
      cache.stubPut();

      await repository.saveUser(const UserEntity(role: UserRole.recruiter));

      verify(
        () => cache.put(
          any(
            that: isA<UserModel>().having((m) => m.role, 'role', 'recruiter'),
          ),
        ),
      ).called(1);
    });
  });
}
