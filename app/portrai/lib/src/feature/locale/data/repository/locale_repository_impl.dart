import 'dart:async';

import 'package:core/core.dart';
import 'package:module_injector/module_injector.dart';
import 'package:portrai/src/feature/locale/data/cache/_cache.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:rxdart/rxdart.dart';

@RegisterSingleton(as: LocaleRepository)
class LocaleRepositoryImpl implements LocaleRepository {
  LocaleRepositoryImpl(AppLocale appLocale, this._appLocaleCache)
    : _appLocale = appLocale,
      _currentAppLocale = appLocale;

  final AppLocaleCache _appLocaleCache;
  final AppLocale _appLocale;
  AppLocale _currentAppLocale;

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
  AppLocale get currentAppLocale => _currentAppLocale;

  @override
  Future<void> updateAppLocale(AppLocale appLocale) async {
    await _appLocaleCache.put(appLocale);

    _currentAppLocale = appLocale;

    Intl.defaultLocale = appLocale.languageCode;

    _localeSubject.add(appLocale);
  }
}
