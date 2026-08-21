import 'package:core/core.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

@immutable
sealed class SystemLocaleObserverEvent extends Equatable {
  const SystemLocaleObserverEvent();

  @override
  List<Object> get props => [];
}

class LoadLocaleEvent extends SystemLocaleObserverEvent {
  const LoadLocaleEvent();
}

class LocaleUpdateEvent extends SystemLocaleObserverEvent {
  const LocaleUpdateEvent(this.locale);

  final AppLocale locale;

  @override
  List<Object> get props => [locale];
}
