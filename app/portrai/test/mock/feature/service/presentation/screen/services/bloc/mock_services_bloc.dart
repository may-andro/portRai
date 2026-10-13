import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/service/presentation/screen/services/bloc/_bloc.dart';

class MockServicesBloc extends MockBloc<ServicesEvent, ServicesState>
    implements ServicesBloc {}

extension MockServicesBlocStub on MockServicesBloc {
  void stubState(ServicesState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<ServicesState>.empty(), initialState: state);
  }
}
