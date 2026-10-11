import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/remote_assistant/presentation/screen/remote_assistant/bloc/_bloc.dart';

class MockRemoteAssistantBloc
    extends MockBloc<RemoteAssistantEvent, RemoteAssistantState>
    implements RemoteAssistantBloc {}

extension MockRemoteAssistantBlocStub on MockRemoteAssistantBloc {
  void stubState(RemoteAssistantState state) {
    when(() => this.state).thenReturn(state);
  }
}
