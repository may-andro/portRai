import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/assistant/presentation/screen/assistant/bloc/_bloc.dart';

class MockAssistantBloc extends MockBloc<AssistantEvent, AssistantState>
    implements AssistantBloc {}

extension MockAssistantBlocStub on MockAssistantBloc {
  void stubState(AssistantState state) {
    when(() => this.state).thenReturn(state);
  }
}
