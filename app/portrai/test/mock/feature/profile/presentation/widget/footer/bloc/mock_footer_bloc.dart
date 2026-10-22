import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/footer/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockFooterBloc extends MockBloc<FooterEvent, FooterState>
    implements FooterBloc {}

extension MockFooterBlocStub on MockFooterBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<FooterBloc>(() => this);
  }

  void stubLoadingState() => stubState(const LoadingState());

  void stubState(FooterState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<FooterState>.empty(), initialState: state);
  }
}
