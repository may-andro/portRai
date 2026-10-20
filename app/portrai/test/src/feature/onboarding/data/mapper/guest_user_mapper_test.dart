import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/onboarding/data/mapper/_mapper.dart';
import 'package:portrai/src/feature/onboarding/data/model/_model.dart';
import 'package:portrai/src/feature/onboarding/domain/_domain.dart';

void main() {
  group('GuestUserMapper', () {
    const mapper = GuestUserMapper();

    test('should map every role to a model and back when round-tripping', () {
      for (final role in UserRole.values) {
        final user = GuestUserEntity(role: role);

        expect(mapper.to(mapper.from(user)), user);
      }
    });

    test('should throw a format exception when the role is unknown', () {
      expect(
        () => mapper.to(const GuestUserModel(role: 'astronaut')),
        throwsFormatException,
      );
    });
  });
}
