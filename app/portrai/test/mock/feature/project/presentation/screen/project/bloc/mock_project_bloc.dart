import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/screen/project/bloc/_bloc.dart';

class MockProjectBloc extends MockBloc<ProjectEvent, ProjectState>
    implements ProjectBloc {}

extension MockProjectBlocStub on MockProjectBloc {
  void stubState(ProjectState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<ProjectState>.empty(), initialState: state);
  }
}
