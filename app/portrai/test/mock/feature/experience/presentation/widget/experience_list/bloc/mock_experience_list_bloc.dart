import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/experience/presentation/widget/experience_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockExperienceListBloc
    extends MockBloc<ExperienceListEvent, ExperienceListState>
    implements ExperienceListBloc {}

extension MockExperienceListBlocStub on MockExperienceListBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ExperienceListBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const ExperienceListState());
    whenListen(
      this,
      const Stream<ExperienceListState>.empty(),
      initialState: const ExperienceListState(),
    );
  }
}
