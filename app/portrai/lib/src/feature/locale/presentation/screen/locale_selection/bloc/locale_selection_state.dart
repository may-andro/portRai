import 'dart:ui';

import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:portrai/src/feature/profile/profile.dart';
import 'package:use_case/use_case.dart';

@immutable
sealed class LocaleSelectionState extends Equatable {
  const LocaleSelectionState();

  @override
  List<Object?> get props => [];
}

class LoadingState extends LocaleSelectionState {
  const LoadingState();
}

class ErrorState extends LocaleSelectionState {
  const ErrorState({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}

// Base class for states that have locale data
sealed class LoadedState extends LocaleSelectionState {
  const LoadedState({
    required this.supportedLocales,
    required this.appLocale,
    this.profile,
  });

  final List<Locale> supportedLocales;
  final AppLocale appLocale;
  final ProfileEntity? profile;

  @override
  List<Object?> get props => [supportedLocales, appLocale, profile];
}

// Loaded state
class LocaleSelectionLoadedState extends LoadedState {
  const LocaleSelectionLoadedState({
    required super.supportedLocales,
    required super.appLocale,
    super.profile,
  });

  LocaleSelectionLoadedState copyWith({
    List<Locale>? supportedLocales,
    AppLocale? appLocale,
  }) {
    return LocaleSelectionLoadedState(
      supportedLocales: supportedLocales ?? this.supportedLocales,
      appLocale: appLocale ?? this.appLocale,
    );
  }
}

// Updating state
class LocaleSelectionUpdatingState extends LoadedState {
  const LocaleSelectionUpdatingState({
    required super.supportedLocales,
    required super.appLocale,
    required this.targetLocale,
  });

  final AppLocale targetLocale;

  @override
  List<Object?> get props => [...super.props, targetLocale];
}

// Update failed state
class LocaleSelectionUpdateFailureState extends LoadedState {
  const LocaleSelectionUpdateFailureState({
    required super.supportedLocales,
    required super.appLocale,
    required this.targetLocale,
    required this.failure,
  });

  final Failure failure;
  final AppLocale targetLocale; // The locale that failed to update

  @override
  List<Object?> get props => [...super.props, failure, targetLocale];
}
