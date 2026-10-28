import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/widget/book_call_entry/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockBookCallEntryBloc
    extends MockBloc<BookCallEntryEvent, BookCallEntryState>
    implements BookCallEntryBloc {}

extension MockBookCallEntryBlocStub on MockBookCallEntryBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<BookCallEntryBloc>(() => this);
  }

  void stubAvailable(bool isAvailable) {
    final state = BookCallEntryState(isAvailable: isAvailable);
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<BookCallEntryState>.empty(),
      initialState: state,
    );
  }
}
