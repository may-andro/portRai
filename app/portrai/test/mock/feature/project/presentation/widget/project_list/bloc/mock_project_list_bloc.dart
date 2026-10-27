import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/project/presentation/widget/project_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockProjectListBloc extends MockBloc<ProjectListEvent, ProjectListState>
    implements ProjectListBloc {}

extension MockProjectListBlocStub on MockProjectListBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ProjectListBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const ProjectListState());
    whenListen(
      this,
      const Stream<ProjectListState>.empty(),
      initialState: const ProjectListState(),
    );
  }
}
