import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/locale_selection_state.dart';

extension LocaleSelectionStateExtensions on LocaleSelectionState {
  bool get isLoading => this is LoadingState;

  bool get isLoaded => this is LocaleSelectionLoadedState;

  bool get isUpdating => this is LocaleSelectionUpdatingState;

  bool get hasError => this is ErrorState;

  bool get hasData => this is LoadedState;

  bool get isUpdatingFailed => this is LocaleSelectionUpdateFailureState;

  // Safe getters that return null if state doesn't have the data
  LoadedState? get dataState =>
      this is LoadedState ? this as LoadedState : null;

  ErrorState? get errorState => this is ErrorState ? this as ErrorState : null;

  LocaleSelectionLoadedState? get loadedState =>
      this is LocaleSelectionLoadedState
      ? this as LocaleSelectionLoadedState
      : null;

  LocaleSelectionUpdatingState? get updatingState =>
      this is LocaleSelectionUpdatingState
      ? this as LocaleSelectionUpdatingState
      : null;

  LocaleSelectionUpdateFailureState? get updateFailureState =>
      this is LocaleSelectionUpdateFailureState
      ? this as LocaleSelectionUpdateFailureState
      : null;
}
