import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/widget/service_list/bloc/_bloc.dart';
import 'package:portrai/src/module_configurator/service_locator.dart';

class MockServiceListBloc extends MockBloc<ServiceListEvent, ServiceListState>
    implements ServiceListBloc {}

extension MockServiceListBlocStub on MockServiceListBloc {
  void registerFactory() {
    appServiceLocator.registerFactory<ServiceListBloc>(() => this);
  }

  void stubState() {
    when(() => state).thenReturn(const ServiceListState());
    whenListen(
      this,
      const Stream<ServiceListState>.empty(),
      initialState: const ServiceListState(),
    );
  }
}
