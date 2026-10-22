import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertise/bloc/_bloc.dart';

class MockExpertiseBloc extends MockBloc<ExpertiseEvent, ExpertiseState>
    implements ExpertiseBloc {}

extension MockExpertiseBlocStub on MockExpertiseBloc {
  void stubState(ExpertiseState state) {
    when(() => this.state).thenReturn(state);
    whenListen(this, const Stream<ExpertiseState>.empty(), initialState: state);
  }
}
