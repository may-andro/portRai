import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/use_case/get_locale_stream_use_case.dart';

import '../../../../../mock/feature/locale/domain/repository/mock_locale_repository.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('GetLocaleStreamUseCase', () {
    test('should return the repository locale stream when called', () async {
      final repository = MockLocaleRepository();
      final stream = Stream.value(createSpanishLocale());
      repository.stubAppLocaleStream(stream);
      final useCase = GetLocaleStreamUseCase(repository);

      expect(await useCase().first, createSpanishLocale());
    });
  });
}
