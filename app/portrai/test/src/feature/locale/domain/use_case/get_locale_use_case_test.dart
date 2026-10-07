import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';

import '../../../../../mock/feature/locale/domain/repository/mock_locale_repository.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('GetLocaleUseCase', () {
    late MockLocaleRepository repository;
    late GetLocaleUseCase useCase;

    setUp(() {
      repository = MockLocaleRepository();
      useCase = GetLocaleUseCase(repository);
    });

    test(
      'should return the current locale when the repository succeeds',
      () async {
        final locale = createEnglishLocale();
        repository.stubAppLocale(locale);

        final result = await useCase();

        expect(result.isRight, isTrue);
        expect(result.right, locale);
      },
    );

    test(
      'should return GetLocaleCacheFailure when the repository throws a cache-related error',
      () async {
        final error = Exception('cache read failed');
        repository.stubAppLocaleThrows(error);

        final result = await useCase();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<GetLocaleCacheFailure>());
        expect(result.left.cause, same(error));
      },
    );

    test(
      'should return GetLocaleUnknownFailure when the repository throws an unexpected error',
      () async {
        final error = Exception('boom');
        repository.stubAppLocaleThrows(error);

        final result = await useCase();

        expect(result.isLeft, isTrue);
        expect(result.left, isA<GetLocaleUnknownFailure>());
        expect(result.left.cause, same(error));
      },
    );
  });
}
