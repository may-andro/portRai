import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/use_case/watch_locale_use_case.dart';

import '../../../../../mock/feature/locale/domain/repository/mock_locale_repository.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('WatchLocaleUseCase', () {
    test('should emit the repository locales when called', () async {
      final repository = MockLocaleRepository()
        ..stubAppLocaleStream(
          Stream.fromIterable([createSpanishLocale(), createDutchLocale()]),
        );

      final results = await WatchLocaleUseCase(repository)().toList();

      expect(results.map((e) => e.right), [
        createSpanishLocale(),
        createDutchLocale(),
      ]);
    });

    test('should emit a failure when the repository stream errors', () async {
      final repository = MockLocaleRepository()
        ..stubAppLocaleStream(Stream.error(Exception('boom')));

      final results = await WatchLocaleUseCase(repository)().toList();

      expect(results.single.left, isA<WatchLocaleUnknownFailure>());
    });
  });
}
