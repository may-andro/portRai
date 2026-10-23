import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/data/cache/design_system_cache.dart';

void main() {
  group('DesignSystemCache', () {
    test('should keep a design system until the start of the next month', () {
      expect(
        DesignSystemCache.timeLeftInMonth(DateTime(2026, 10, 23, 18, 30)),
        DateTime(2026, 11).difference(DateTime(2026, 10, 23, 18, 30)),
      );
    });

    test('should keep a design system chosen on the last second of a month '
        'for that second only', () {
      expect(
        DesignSystemCache.timeLeftInMonth(DateTime(2026, 10, 31, 23, 59, 59)),
        const Duration(seconds: 1),
      );
    });

    test('should keep a design system chosen on the first day of a month for '
        'the whole month', () {
      expect(
        DesignSystemCache.timeLeftInMonth(DateTime(2026, 2)),
        const Duration(days: 28),
      );
    });

    test('should keep a design system chosen in December until the start of '
        'the next year', () {
      expect(
        DesignSystemCache.timeLeftInMonth(DateTime(2026, 12, 15)),
        DateTime(2027).difference(DateTime(2026, 12, 15)),
      );
    });

    test('should serialize the design system by name', () {
      expect(DesignSystemCache().serializeValue(DesignSystem.obon), {
        'designSystem': 'obon',
      });
    });

    test('should restore the design system from its name', () {
      expect(
        DesignSystemCache().deserializeValue({'designSystem': 'sakura'}),
        DesignSystem.sakura,
      );
    });
  });
}
