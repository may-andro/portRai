import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:log_reporter/log_reporter.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_event.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_state.dart';

const _logTag = 'SystemLocaleObserverBloc';

class SystemLocaleObserverBloc
    extends Bloc<SystemLocaleObserverEvent, SystemLocaleObserverState> {
  SystemLocaleObserverBloc({
    required GetLocaleUseCase getLocaleUseCase,
    required UpdateLocaleUseCase updateLocaleUseCase,
    required LogReporter logReporter,
  }) : _getLocaleUseCase = getLocaleUseCase,
       _updateLocaleUseCase = updateLocaleUseCase,
       _logReporter = logReporter,
       super(const LoadingState()) {
    on<LoadLocaleEvent>(_onLoadLocaleEventToState);
    on<LocaleUpdateEvent>(_onLocaleUpdateEventToState);
  }

  final GetLocaleUseCase _getLocaleUseCase;
  final UpdateLocaleUseCase _updateLocaleUseCase;
  final LogReporter _logReporter;

  Future<void> _onLoadLocaleEventToState(
    LoadLocaleEvent event,
    Emitter<SystemLocaleObserverState> emit,
  ) async {
    try {
      final localeResult = await _getLocaleUseCase();
      localeResult.fold(
        (failure) {
          _logReporter.error(
            'Failed to initialize SystemLocaleObserver: $failure',
            tag: _logTag,
          );
        },
        (currentLocale) {
          emit(LoadedState(currentLocale: currentLocale));
          _logReporter.debug(
            'SystemLocaleObserver initialized with locale: ${currentLocale.languageCode}',
            tag: _logTag,
          );
        },
      );
    } catch (error) {
      _logReporter.error(
        'Failed to initialize SystemLocaleObserver: $error',
        tag: _logTag,
      );
    }
  }

  Future<void> _onLocaleUpdateEventToState(
    LocaleUpdateEvent event,
    Emitter<SystemLocaleObserverState> emit,
  ) async {
    final currentState = state;

    if (currentState is! LoadedState) {
      return;
    }

    final currentLocale = currentState.currentLocale;
    final newLocale = event.locale;

    if (newLocale == currentLocale) {
      return;
    }

    emit(currentState.copyWith(updatingLocale: newLocale));

    final updateResult = await _updateLocaleUseCase(newLocale);
    updateResult.fold(
      (failure) {
        // Revert to previous locale on error
        emit(currentState.updateLocale(currentLocale));
        _logReporter.error(
          'Failed to update locale to ${newLocale.languageCode}: $failure',
          tag: _logTag,
        );
      },
      (_) {
        emit(currentState.updateLocale(newLocale));
        _logReporter.debug(
          'App locale updated from ${currentLocale.languageCode} to ${newLocale.languageCode}',
          tag: _logTag,
        );
      },
    );
  }
}
