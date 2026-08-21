import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SystemLocaleObserverState extends Equatable {
  const SystemLocaleObserverState();

  @override
  List<Object?> get props => [];
}

class LoadingState extends SystemLocaleObserverState {
  const LoadingState();
}

class LoadedState extends SystemLocaleObserverState {
  const LoadedState({required this.currentLocale, this.updatingLocale});

  final AppLocale currentLocale;
  final AppLocale? updatingLocale;

  LoadedState copyWith({AppLocale? currentLocale, AppLocale? updatingLocale}) {
    return LoadedState(
      currentLocale: currentLocale ?? this.currentLocale,
      updatingLocale: updatingLocale ?? this.updatingLocale,
    );
  }

  LoadedState updateLocale(AppLocale locale) {
    return LoadedState(currentLocale: locale);
  }

  @override
  List<Object?> get props => [currentLocale, updatingLocale];
}
