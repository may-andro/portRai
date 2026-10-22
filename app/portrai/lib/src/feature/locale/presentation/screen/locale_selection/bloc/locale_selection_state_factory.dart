import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state.dart';

class LocaleSelectionStateFactory {
  LocaleSelectionStateFactory._();

  static LoadingState loading() {
    return const LoadingState();
  }

  static ErrorState loadError({required GetLocaleFailure failure}) {
    return ErrorState(failure: failure);
  }

  static LocaleSelectionLoadedState loaded({
    required List<Locale> supportedLocales,
    required AppLocale appLocale,
  }) {
    return LocaleSelectionLoadedState(
      supportedLocales: supportedLocales,
      appLocale: appLocale,
    );
  }

  static LocaleSelectionUpdatingState updating({
    required List<Locale> supportedLocales,
    required AppLocale appLocale,
    required AppLocale targetLocale,
  }) {
    return LocaleSelectionUpdatingState(
      supportedLocales: supportedLocales,
      appLocale: appLocale,
      targetLocale: targetLocale,
    );
  }

  static LocaleSelectionUpdateFailureState updateFailure({
    required List<Locale> supportedLocales,
    required AppLocale appLocale,
    required UpdateLocaleFailure failure,
    required AppLocale targetLocale,
  }) => LocaleSelectionUpdateFailureState(
    supportedLocales: supportedLocales,
    appLocale: appLocale,
    failure: failure,
    targetLocale: targetLocale,
  );
}
