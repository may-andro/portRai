import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/screen/service/bloc/_bloc.dart';

class MockServiceBloc extends MockBloc<ServiceEvent, ServiceState>
    implements ServiceBloc {}

extension MockServiceBlocStub on MockServiceBloc {
  void stubState(ServiceState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<ServiceState>.empty(), initialState: state);
  }
}
