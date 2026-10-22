import 'dart:ui';

import 'package:core/core.dart';

AppLocale createEnglishLocale() => AppLocale('en');

AppLocale createDutchLocale() => AppLocale('nl');

AppLocale createSpanishLocale() => AppLocale('es');

List<Locale> createSupportedLocales() => const [
  Locale('en'),
  Locale('nl'),
  Locale('es'),
];
