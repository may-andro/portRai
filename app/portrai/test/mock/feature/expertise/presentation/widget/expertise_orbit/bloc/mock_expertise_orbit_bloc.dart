import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_orbit/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockExpertiseOrbitBloc
    extends MockBloc<ExpertiseOrbitEvent, ExpertiseOrbitState>
    implements ExpertiseOrbitBloc {}

extension MockExpertiseOrbitBlocStub on MockExpertiseOrbitBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ExpertiseOrbitBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const ExpertiseOrbitState());
    whenListen(
      this,
      const Stream<ExpertiseOrbitState>.empty(),
      initialState: const ExpertiseOrbitState(),
    );
  }
}
