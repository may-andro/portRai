import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_opening/bloc/_bloc.dart';

class MockJobOpeningBloc extends MockBloc<JobOpeningEvent, JobOpeningState>
    implements JobOpeningBloc {}

extension MockJobOpeningBlocStub on MockJobOpeningBloc {
  void stubState(JobOpeningState state) {
    when(() => this.state).thenReturn(state);
  }

  /// Starts at [initialState] and then emits each of [states].
  void stubStates(
    Stream<JobOpeningState> states, {
    required JobOpeningState initialState,
  }) {
    whenListen(this, states, initialState: initialState);
  }
}
