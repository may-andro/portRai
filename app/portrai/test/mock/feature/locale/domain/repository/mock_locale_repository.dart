import 'package:core/core.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';

class MockLocaleRepository extends Mock implements LocaleRepository {}

extension MockLocaleRepositoryStub on MockLocaleRepository {
  void stubAppLocale(AppLocale locale) {
    when(() => appLocale).thenAnswer((_) async => locale);
  }

  void stubAppLocaleThrows(Object error) {
    when(() => appLocale).thenThrow(error);
  }

  void stubAppLocaleStream(Stream<AppLocale> stream) {
    when(() => appLocaleStream).thenAnswer((_) => stream);
  }

  void stubUpdateAppLocale(AppLocale locale) {
    when(() => updateAppLocale(locale)).thenAnswer((_) async {});
  }

  void stubUpdateAppLocaleThrows({
    required AppLocale locale,
    required Object error,
  }) {
    when(() => updateAppLocale(locale)).thenThrow(error);
  }
}
