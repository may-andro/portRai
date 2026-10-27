import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/widget/expertise_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockExpertiseListBloc
    extends MockBloc<ExpertiseListEvent, ExpertiseListState>
    implements ExpertiseListBloc {}

extension MockExpertiseListBlocStub on MockExpertiseListBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ExpertiseListBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const ExpertiseListState());
    whenListen(
      this,
      const Stream<ExpertiseListState>.empty(),
      initialState: const ExpertiseListState(),
    );
  }
}
