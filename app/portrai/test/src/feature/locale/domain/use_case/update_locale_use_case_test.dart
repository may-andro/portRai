import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';

import '../../../../../mock/feature/locale/domain/repository/mock_locale_repository.dart';
import '../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('UpdateLocaleUseCase', () {
    late MockLocaleRepository repository;
    late UpdateLocaleUseCase useCase;

    setUp(() {
      repository = MockLocaleRepository();
      useCase = UpdateLocaleUseCase(repository);
    });

    test(
      'should return success when the repository updates the locale',
      () async {
        final locale = createDutchLocale();
        repository.stubUpdateAppLocale(locale);

        final result = await useCase(locale);

        expect(result.isRight, isTrue);
      },
    );

    test(
      'should return UpdateLocaleCacheFailure when the repository throws a cache-related error',
      () async {
        final locale = createDutchLocale();
        final error = Exception('cache write failed');
        repository.stubUpdateAppLocaleThrows(locale: locale, error: error);

        final result = await useCase(locale);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<UpdateLocaleCacheFailure>());
        expect(result.left.cause, same(error));
      },
    );

    test(
      'should return UpdateLocaleServiceLocatorFailure when the repository throws a service locator error',
      () async {
        final locale = createSpanishLocale();
        final error = Exception('register dependency failed');
        repository.stubUpdateAppLocaleThrows(locale: locale, error: error);

        final result = await useCase(locale);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<UpdateLocaleServiceLocatorFailure>());
        expect(result.left.cause, same(error));
      },
    );

    test(
      'should return UpdateLocaleUnknownFailure when the repository throws an unexpected error',
      () async {
        final locale = createEnglishLocale();
        final error = Exception('boom');
        repository.stubUpdateAppLocaleThrows(locale: locale, error: error);

        final result = await useCase(locale);

        expect(result.isLeft, isTrue);
        expect(result.left, isA<UpdateLocaleUnknownFailure>());
        expect(result.left.cause, same(error));
      },
    );
  });
}
