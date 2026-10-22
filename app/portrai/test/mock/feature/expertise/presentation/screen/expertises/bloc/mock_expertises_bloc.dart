import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portrai/src/feature/expertise/presentation/screen/expertises/bloc/_bloc.dart';

class MockExpertisesBloc extends MockBloc<ExpertisesEvent, ExpertisesState>
    implements ExpertisesBloc {}

extension MockExpertisesBlocStub on MockExpertisesBloc {
  void stubState(ExpertisesState state) {
    when(() => this.state).thenReturn(state);
    whenListen(
      this,
      const Stream<ExpertisesState>.empty(),
      initialState: state,
    );
  }
}
