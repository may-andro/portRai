import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/developer_mode/presentation/screen/developer_menu/bloc/_bloc.dart';

class MockDeveloperMenuBloc
    extends MockBloc<DeveloperMenuEvent, DeveloperMenuState>
    implements DeveloperMenuBloc {}

extension MockDeveloperMenuBlocStub on MockDeveloperMenuBloc {
  void stubState(DeveloperMenuState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<DeveloperMenuState>.empty(),
      initialState: state,
    );
  }
}
