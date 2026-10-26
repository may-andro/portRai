import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/user/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/user/data/model/_model.dart';
import 'package:portrai/src/feature/user/data/repository/_repository.dart';
import 'package:portrai/src/feature/user/domain/_domain.dart';

import '../../../../../mock/feature/user/data/cache/mock_guest_user_cache.dart';
import '../../../../../mock/feature/user/data/model/fake_guest_user_model.dart';

void main() {
  setUpAll(() => registerFallbackValue(FakeGuestUserModel()));

  group('GuestUserRepositoryImpl', () {
    late MockGuestUserCache cache;
    late GuestUserRepositoryImpl repository;

    setUp(() {
      cache = MockGuestUserCache();
      repository = GuestUserRepositoryImpl(cache, const GuestUserMapper());
    });

    test('should return the mapped user when the cache has one', () async {
      cache.stubGet(const GuestUserModel(role: 'developer'));

      final user = await repository.getGuestUser();

      expect(user, const GuestUserEntity(role: UserRole.developer));
    });

    test('should return null when the cache is empty', () async {
      cache.stubGet(null);

      expect(await repository.getGuestUser(), isNull);
    });

    test('should return null when the cache read throws', () async {
      cache.stubGetThrows(StateError('broken'));

      expect(await repository.getGuestUser(), isNull);
    });

    test('should return null when the cached role is unknown', () async {
      cache.stubGet(const GuestUserModel(role: 'astronaut'));

      expect(await repository.getGuestUser(), isNull);
    });

    test('should store the mapped model when saving a user', () async {
      cache.stubPut();

      await repository.saveGuestUser(
        const GuestUserEntity(role: UserRole.recruiter),
      );

      verify(
        () => cache.put(
          any(
            that: isA<GuestUserModel>().having(
              (m) => m.role,
              'role',
              'recruiter',
            ),
          ),
        ),
      ).called(1);
    });
  });
}
