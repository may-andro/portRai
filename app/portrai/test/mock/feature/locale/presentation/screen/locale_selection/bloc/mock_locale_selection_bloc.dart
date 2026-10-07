import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/locale/presentation/screen/locale_selection/bloc/_bloc.dart';

class MockLocaleSelectionBloc
    extends MockBloc<LocaleSelectionEvent, LocaleSelectionState>
    implements LocaleSelectionBloc {}

extension MockLocaleSelectionBlocStub on MockLocaleSelectionBloc {
  void stubState(LocaleSelectionState blocState) {
    when(() => state).thenReturn(blocState);
    whenListen(
      this,
      Stream<LocaleSelectionState>.value(blocState),
      initialState: blocState,
    );
  }

  void stubStateStream({
    required LocaleSelectionState initialState,
    required Stream<LocaleSelectionState> states,
  }) {
    when(() => state).thenReturn(initialState);
    whenListen(this, states, initialState: initialState);
  }
}
