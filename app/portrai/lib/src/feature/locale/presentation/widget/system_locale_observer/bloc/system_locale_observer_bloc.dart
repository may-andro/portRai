import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:portrai/src/feature/locale/domain/_domain.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_event.dart';
import 'package:portrai/src/feature/locale/presentation/widget/system_locale_observer/bloc/system_locale_observer_state.dart';

class SystemLocaleObserverBloc
    extends Bloc<SystemLocaleObserverEvent, SystemLocaleObserverState> {
  SystemLocaleObserverBloc({
    required GetLocaleUseCase getLocaleUseCase,
    required UpdateLocaleUseCase updateLocaleUseCase,
  }) : _getLocaleUseCase = getLocaleUseCase,
       _updateLocaleUseCase = updateLocaleUseCase,
       super(const LoadingState()) {
    on<LoadLocaleEvent>(_onLoadLocaleEventToState);
    on<LocaleUpdateEvent>(_onLocaleUpdateEventToState);
  }

  final GetLocaleUseCase _getLocaleUseCase;
  final UpdateLocaleUseCase _updateLocaleUseCase;

  Future<void> _onLoadLocaleEventToState(
    LoadLocaleEvent event,
    Emitter<SystemLocaleObserverState> emit,
  ) async {
    final localeResult = await _getLocaleUseCase();
    if (localeResult.isRight) {
      emit(LoadedState(currentLocale: localeResult.right));
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
    if (updateResult.isRight) {
      emit(currentState.updateLocale(newLocale));
      return;
    }

    emit(currentState.updateLocale(currentLocale));
  }
}
