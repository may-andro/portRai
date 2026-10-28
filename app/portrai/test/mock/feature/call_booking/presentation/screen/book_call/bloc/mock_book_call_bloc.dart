import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/call_booking/presentation/screen/book_call/bloc/_bloc.dart';

class MockBookCallBloc extends MockBloc<BookCallEvent, BookCallState>
    implements BookCallBloc {}

extension MockBookCallBlocStub on MockBookCallBloc {
  void stubState(BookCallState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<BookCallState>.empty(), initialState: state);
  }
}
