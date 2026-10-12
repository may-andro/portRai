import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/ai_image_gen/presentation/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockAiImageBloc extends MockBloc<AiImageEvent, AiImageState>
    implements AiImageBloc {}

extension MockAiImageBlocStub on MockAiImageBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<AiImageBloc>(() => this);
  }

  void stubLoadingState() => stubState(const LoadingState());

  void stubState(AiImageState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<AiImageState>.empty(), initialState: state);
  }
}
