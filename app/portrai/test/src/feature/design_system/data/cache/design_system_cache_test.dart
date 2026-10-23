import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/data/cache/design_system_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('DesignSystemCache', () {
    const cacheKey = 'design_system_cache';
    const expirationKey = 'design_system_cache.expiration';

    void storeDesignSystem(DesignSystem designSystem, DateTime cachedAt) {
      SharedPreferences.setMockInitialValues({
        cacheKey: '{"designSystem":"${designSystem.name}"}',
        expirationKey: cachedAt.millisecondsSinceEpoch,
      });
    }

    test(
      'should return the design system when it was chosen this month',
      () async {
        storeDesignSystem(DesignSystem.holi, DateTime.now());

        final cachedDesignSystem = await DesignSystemCache().get();

        expect(cachedDesignSystem, DesignSystem.holi);
      },
    );

    test(
      'should drop the design system when it was chosen in an earlier month',
      () async {
        final now = DateTime.now();
        storeDesignSystem(DesignSystem.holi, DateTime(now.year, now.month, 0));

        final cache = DesignSystemCache();
        final cachedDesignSystem = await cache.get();

        expect(cachedDesignSystem, isNull);
        final preferences = await SharedPreferences.getInstance();
        expect(preferences.containsKey(cacheKey), isFalse);
      },
    );

    test('should drop the design system when it was chosen in the same month '
        'of an earlier year', () async {
      final now = DateTime.now();
      storeDesignSystem(DesignSystem.holi, DateTime(now.year - 1, now.month));

      final cachedDesignSystem = await DesignSystemCache().get();

      expect(cachedDesignSystem, isNull);
    });

    test('should keep a design system that was just saved', () async {
      SharedPreferences.setMockInitialValues({});
      final cache = DesignSystemCache();

      await cache.put(DesignSystem.sakura);

      expect(await cache.get(), DesignSystem.sakura);
    });

    test('should serialize the design system by name', () {
      expect(DesignSystemCache().serializeValue(DesignSystem.obon), {
        'designSystem': 'obon',
      });
    });
  });
}
