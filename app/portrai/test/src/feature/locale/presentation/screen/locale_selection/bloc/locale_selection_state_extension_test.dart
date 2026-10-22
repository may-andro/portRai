import 'package:flutter_test/flutter_test.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';

import '../../../../../../../mock/feature/locale/test_data/locale_test_data.dart';

void main() {
  group('LocaleSelectionStateExtensions', () {
    test('should expose flags and typed getters for each state variant', () {
      const loading = LoadingState();
      const error = ErrorState(failure: GetLocaleUnknownFailure());
      final loaded = LocaleSelectionStateFactory.loaded(
        supportedLocales: createSupportedLocales(),
        appLocale: createEnglishLocale(),
      );
      final updating = LocaleSelectionStateFactory.updating(
        supportedLocales: createSupportedLocales(),
        appLocale: createEnglishLocale(),
        targetLocale: createDutchLocale(),
      );
      final updateFailure = LocaleSelectionStateFactory.updateFailure(
        supportedLocales: createSupportedLocales(),
        appLocale: createEnglishLocale(),
        targetLocale: createSpanishLocale(),
        failure: const UpdateLocaleUnknownFailure(),
      );

      expect(loading.isLoading, isTrue);
      expect(error.hasError, isTrue);
      expect(error.errorState, same(error));
      expect(loaded.isLoaded, isTrue);
      expect(loaded.hasData, isTrue);
      expect(loaded.loadedState, same(loaded));
      expect(updating.isUpdating, isTrue);
      expect(updating.updatingState, same(updating));
      expect(updateFailure.isUpdatingFailed, isTrue);
      expect(updateFailure.updateFailureState, same(updateFailure));
    });
  });
}
