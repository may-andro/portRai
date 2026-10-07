import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/data/cache/app_locale_cache.dart';

import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('AppLocaleCache', () {
    late AppLocaleCache cache;

    setUp(() {
      cache = AppLocaleCache();
    });

    test('should serialize the language code when writing a locale', () {
      final locale = createDutchLocale();

      final result = cache.serializeValue(locale);

      expect(result, {'languageCode': 'nl'});
    });

    test('should restore the language code when reading a locale', () {
      final result = cache.deserializeValue({'languageCode': 'es'});

      expect(result, createSpanishLocale());
    });
  });
}
