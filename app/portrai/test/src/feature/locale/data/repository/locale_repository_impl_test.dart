import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/data/repository/locale_repository_impl.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

import '../../../../../mock/feature/locale/data/cache/fake_app_locale_cache.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('LocaleRepositoryImpl', () {
    late FakeAppLocaleCache cache;
    late LocaleRepositoryImpl repository;
    late AppLocale fallbackLocale;

    setUp(() async {
      await appServiceLocator.reset();
      fallbackLocale = createEnglishLocale();
      cache = FakeAppLocaleCache();
      repository = LocaleRepositoryImpl(fallbackLocale, cache);
      appServiceLocator.registerSingleton<AppLocale>(() => fallbackLocale);
    });

    tearDown(() async {
      Intl.defaultLocale = null;
      await appServiceLocator.reset();
    });

    test('should return the cached locale when one exists', () async {
      await cache.put(createDutchLocale());

      final result = await repository.appLocale;

      expect(result, createDutchLocale());
    });

    test('should return the fallback locale when the cache is empty', () async {
      final result = await repository.appLocale;

      expect(result, fallbackLocale);
    });

    test(
      'should persist the locale update and notify listeners when the locale changes',
      () async {
        final updatedLocale = createSpanishLocale();
        final streamValue = repository.appLocaleStream.first;

        await repository.updateAppLocale(updatedLocale);

        expect(await cache.get(), updatedLocale);
        expect(appServiceLocator.get<AppLocale>(), updatedLocale);
        expect(Intl.defaultLocale, updatedLocale.languageCode);
        expect(await streamValue, updatedLocale);
      },
    );
  });
}
