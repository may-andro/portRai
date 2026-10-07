import 'package:core/core.dart';
import 'package:portrai/src/feature/locale/data/cache/app_locale_cache.dart';

class FakeAppLocaleCache extends AppLocaleCache {
  AppLocale? _storedLocale;

  @override
  Future<AppLocale?> get() async => _storedLocale;

  @override
  Future<bool> put(AppLocale value) async {
    _storedLocale = value;
    return true;
  }

  @override
  Future<bool> delete() async {
    _storedLocale = null;
    return true;
  }
}
