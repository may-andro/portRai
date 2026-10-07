import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/setting/presentation/screen/setting/bloc/_bloc.dart';

class MockSettingBloc extends MockBloc<SettingEvent, SettingState>
    implements SettingBloc {}

extension MockSettingBlocStub on MockSettingBloc {
  void stubState(SettingState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, Stream<SettingState>.value(state), initialState: state);
  }
}
