import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/l10n/l10n.dart';
import 'package:portrai/src/feature/locale/presentation/extension/locale_code_extension.dart';

void main() {
  group('LocaleCodeExtension', () {
    late AppLocalizations localizations;

    setUp(() async {
      localizations = await AppLocalizations.delegate.load(const Locale('en'));
    });

    test('should return the English label when the code is en', () {
      expect('en'.languageName(localizations), '🇬🇧 English');
    });

    test('should return the Dutch label when the code is nl', () {
      expect('nl'.languageName(localizations), '🇳🇱 Dutch');
    });

    test('should return the Spanish label when the code is es', () {
      expect('es'.languageName(localizations), '🇪🇸 Spanish');
    });

    test('should return the fallback label when the code is unsupported', () {
      expect('fr'.languageName(localizations), 'Unknown Language');
    });
  });
}
