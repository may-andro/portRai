import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/local_assistant/presentation/screen/local_assistant/bloc/_bloc.dart';

class MockLocalAssistantBloc
    extends MockBloc<LocalAssistantEvent, LocalAssistantState>
    implements LocalAssistantBloc {}

extension MockLocalAssistantBlocStub on MockLocalAssistantBloc {
  void stubState(LocalAssistantState state) {
    when(() => this.state).thenReturn(state);
    stubPlatformSupported(true);
  }

  void stubPlatformSupported(bool supported) {
    when(() => isPlatformSupported).thenReturn(supported);
  }
}
