import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/job_opening/presentation/screen/job_openings/bloc/_bloc.dart';

class MockJobOpeningsBloc extends MockBloc<JobOpeningsEvent, JobOpeningsState>
    implements JobOpeningsBloc {}

extension MockJobOpeningsBlocStub on MockJobOpeningsBloc {
  void stubState(JobOpeningsState state) {
    when(() => this.state).thenReturn(state);
  }
}
