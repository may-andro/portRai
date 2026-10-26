import 'package:core/core.dart';

abstract class LocaleRepository {
  Stream<AppLocale> get appLocaleStream;

  Future<AppLocale> get appLocale;

  /// The locale in use: the start locale until [updateAppLocale] changes it.
  AppLocale get currentAppLocale;

  Future<void> updateAppLocale(AppLocale appLocale);
}
