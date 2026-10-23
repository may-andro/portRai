import 'package:design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/design_system/data/cache/design_system_cache.dart';

void main() {
  group('DesignSystemCache', () {
    test('should expire a design system at the start of the next month', () {
      expect(
        DesignSystemCache().expiryOf(DateTime(2026, 10, 23, 18, 30)),
        DateTime(2026, 11),
      );
    });

    test('should expire a design system chosen on the last moment of a month '
        'at the start of the next month', () {
      expect(
        DesignSystemCache().expiryOf(DateTime(2026, 10, 31, 23, 59, 59)),
        DateTime(2026, 11),
      );
    });

    test('should expire a design system chosen in December at the start of '
        'the next year', () {
      expect(
        DesignSystemCache().expiryOf(DateTime(2026, 12, 15)),
        DateTime(2027),
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
