import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/profile/presentation/widget/professional_summary/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockProfessionalSummaryBloc
    extends MockBloc<ProfessionalSummaryEvent, ProfessionalSummaryState>
    implements ProfessionalSummaryBloc {}

extension MockProfessionalSummaryBlocStub on MockProfessionalSummaryBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ProfessionalSummaryBloc>(() => this);
  }

  void stubLoadingState() => stubState(const LoadingState());

  void stubState(ProfessionalSummaryState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ProfessionalSummaryState>.empty(),
      initialState: state,
    );
  }
}
