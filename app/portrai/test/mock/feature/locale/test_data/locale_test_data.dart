import 'dart:ui';

import 'package:core/core.dart';
import 'package:portrai/src/feature/profile/profile.dart';

import '../../profile/test_data/profile_test_data.dart';

AppLocale createEnglishLocale() => AppLocale('en');

AppLocale createDutchLocale() => AppLocale('nl');

AppLocale createSpanishLocale() => AppLocale('es');

List<Locale> createSupportedLocales() => const [
  Locale('en'),
  Locale('nl'),
  Locale('es'),
];

ProfileEntity createLocaleProfile() => createProfileEntity();
