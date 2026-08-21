import 'dart:async';

import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/data/cache/_cache.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';
import 'package:rxdart/rxdart.dart';

@RegisterSingleton(as: LocaleRepository)
class LocaleRepositoryImpl implements LocaleRepository {
  LocaleRepositoryImpl(this._appLocale, this._appLocaleCache);

  final AppLocaleCache _appLocaleCache;
  final AppLocale _appLocale;

  final _localeSubject = BehaviorSubject<AppLocale>();

  @override
  Stream<AppLocale> get appLocaleStream => _localeSubject.stream.distinct();

  @override
  Future<AppLocale> get appLocale async {
    final cachedLocale = await _appLocaleCache.get();
    if (cachedLocale != null) {
      return cachedLocale;
    }
    return _appLocale;
  }

  @override
  Future<void> updateAppLocale(AppLocale appLocale) async {
    await _appLocaleCache.put(appLocale);

    await appServiceLocator.unregister<AppLocale>();
    appServiceLocator.registerSingleton<AppLocale>(() => appLocale);

    Intl.defaultLocale = appLocale.languageCode;

    _localeSubject.add(appLocale);
  }
}
